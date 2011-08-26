require 'minitest/autorun'
require "active_record"
require "auto_strip_attributes"
#require 'ruby-debug'

class ActiveRecord::Base
  alias_method :save, :valid?
  def self.columns()
    @columns ||= []
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    @columns ||= []
    @columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type, null)
  end
end
