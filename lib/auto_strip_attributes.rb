require "auto_strip_attributes/version"

module AutoStripAttributes
  def auto_strip_attributes(*attributes)
    options = AutoStripAttributes::Config.filters_enabled
    if attributes.last.is_a?(Hash)
      options = options.merge(attributes.pop)
    end

    attributes.each do |attribute|
      before_validation do |record|
        value = if record.is_a?(ActiveRecord::Base)
          record.read_attribute_before_type_cast(attribute.to_s)
        else
          record.send(attribute)
        end

        AutoStripAttributes::Config.filters_order.each do |filter_name|
          next unless options[filter_name]
          value = AutoStripAttributes::Config.filters[filter_name].call(value)
          record[attribute] = value
        end
      end
    end
  end
end

class AutoStripAttributes::Config
  class << self
    attr_accessor :filters
    attr_accessor :filters_enabled
    attr_accessor :filters_order
  end

  def self.setup(user_options=nil,&block)
    options = {
        :clear => false,
        :defaults => true,
    }
    options = options.merge user_options if user_options.is_a?(Hash)

    @filters, @filters_enabled, @filters_order = {}, {}, [] if options[:clear]

    @filters ||= {}
    @filters_enabled ||= {}
    @filters_order ||= []

    if options[:defaults]
      set_filter :convert_non_breaking_spaces => false do |value|
        value.respond_to?(:gsub) ? value.gsub("\u00A0", " ") : value
      end
      set_filter :strip => true do |value|
        value.respond_to?(:strip) ? value.strip : value
      end
      set_filter :nullify => true do |value|
        # We check for blank? and empty? because rails uses empty? inside blank?
        # e.g. MiniTest::Mock.new() only responds to .blank? but not empty?, check tests for more info
        # Basically same as value.blank? ? nil : value
        (value.respond_to?(:'blank?') and value.respond_to?(:'empty?') and value.blank?) ? nil : value
      end
      set_filter :squish => false do |value|
        value.respond_to?(:gsub) ? value.gsub(/\s+/, ' ') : value
      end
      set_filter :delete_whitespaces => false do |value|
        value.respond_to?(:delete) ? value.delete(" \t") : value
      end
    end

    instance_eval(&block) if block_given?
  end

  def self.set_filter(filter,&block)
    if filter.is_a?(Hash) then
      filter_name = filter.keys.first
      filter_enabled = filter.values.first
    else
      filter_name = filter
      filter_enabled = false
    end
    @filters[filter_name] = block
    @filters_enabled[filter_name] = filter_enabled
    # in case filter is redefined, we probably don't want to change the order
    @filters_order << filter_name unless @filters_order.include? filter_name
  end
end

ActiveRecord::Base.send(:extend, AutoStripAttributes) if defined? ActiveRecord
AutoStripAttributes::Config.setup
#ActiveModel::Validations::HelperMethods.send(:include, AutoStripAttributes) if defined? ActiveRecord
