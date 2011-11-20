require "auto_strip_attributes/version"

module AutoStripAttributes
  def auto_strip_attributes(*attributes)
    options = AutoStripAttributes::Config.filters_enabled
    if attributes.last.is_a?(Hash)
      options = options.merge(attributes.pop)
    end

    attributes.each do |attribute|
      before_validation do |record|
        value = record[attribute]
        AutoStripAttributes::Config.filters_order.each do |filter_name|
          next unless options[filter_name]
          value = AutoStripAttributes::Config.filters[filter_name].call value
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

  def self.setup(reset_filters=false,&block)
    if reset_filters
      @filters, @filters_enabled, @filters_order = {}, {}, []
    end
    @filters ||= {}
    @filters_enabled ||= {}
    @filters_order ||= []

    instance_eval &block if block_given?
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
AutoStripAttributes::Config.setup do
  set_filter :strip => true do |value|
    value.respond_to?(:strip) ? value.strip : value
  end
  set_filter :nullify => true do |value|
    #test fail in ruby 1.9 when value is set to MiniTest::Mock.new(), it responds to blank? but doesn't respond to !
    #rails blank? method returns !self if an object doesn't respond to :empty?, so we make sure value has ! method
    #defined before calling blank?
    (value.respond_to?('!') and value.blank?) ? nil : value
  end
  set_filter :squish => false do |value|
    value.respond_to?(:gsub) ? value.gsub(/\s+/, ' ') : value
  end
end
#ActiveModel::Validations::HelperMethods.send(:include, AutoStripAttributes) if defined? ActiveRecord

