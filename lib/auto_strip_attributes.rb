require "auto_strip_attributes/version"

module AutoStripAttributes
  def auto_strip_attributes(*attributes)
    options = AutoStripAttributes::Config.filters_enabled
    if attributes.last.is_a?(Hash)
      options = options.merge(attributes.pop)
    end

    # option `:virtual` is needed because we want to guarantee that
    # getter/setter methods for an attribute will _not_ be invoked by default
    virtual = options.delete(:virtual)

    attributes.each do |attribute|
      before_validation do |record|
        #debugger
        if virtual
          value = record.public_send(attribute)
        else
          value = record[attribute]
        end
        AutoStripAttributes::Config.filters_order.each do |filter_name|
          next unless options[filter_name]
          value = AutoStripAttributes::Config.filters[filter_name].call value, options[filter_name]
          if virtual
            record.public_send("#{attribute}=", value)
          else
            record[attribute] = value
          end
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
        value = value.respond_to?(:gsub) ? value.gsub(/[[:space:]]+/, ' ') : value
        value.respond_to?(:strip) ? value.strip : value
      end
      set_filter :delete_whitespaces => false do |value|
        value.respond_to?(:delete) ? value.delete(" \t") : value
      end
      set_filter :truncate => false do |value, options|
        unless options.is_a?(Integer) && options > 0
          raise "Expected :truncate option to be a positive integer, found #{options.inspect} instead"
        end
        value.to_s[0, options]
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
