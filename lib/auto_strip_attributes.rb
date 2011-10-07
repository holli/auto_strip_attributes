require "auto_strip_attributes/version"

module AutoStripAttributes

  def auto_strip_attributes(*attributes)
    options = {:nullify => true, :squish => false}
    if attributes.last.is_a?(Hash)
      options = options.merge(attributes.pop)
    end

    attributes.each do |attribute|
      before_validation do |record|
        #value = record.send(attribute)
        value = record[attribute]
        if value.respond_to?(:strip)
          value_stripped = (options[:nullify] && value.blank?) ? nil : value.strip

          # gsub(/\s+/, ' ') is same as in Rails#String.squish http://api.rubyonrails.org/classes/String.html#method-i-squish-21
          value_stripped = value_stripped.gsub(/\s+/, ' ') if options[:squish] && value_stripped.respond_to?(:gsub)

          record[attribute] = value_stripped

          # Alternate way would be to use send(attribute=)
          # But that would end up calling =-method twice, once when setting, once in before_validate
          # if (attr != attr_stripped)
          #   record.send("#{attribute}=", value_stripped) # does add some overhead, attribute= will be called before each validation
          # end
        end
      end
    end
  end

end

ActiveRecord::Base.send(:extend, AutoStripAttributes) if defined? ActiveRecord
#ActiveModel::Validations::HelperMethods.send(:include, AutoStripAttributes) if defined? ActiveRecord

