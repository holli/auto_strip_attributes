class MockRecordParent
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  extend AutoStripAttributes

  # Overriding @record[key]=val , that's only found in activerecord, not in ActiveModel
  def []=(key, val)
    # send("#{key}=", val)  # We dont want to call setter again
    instance_variable_set(:"@#{key}", val)
  end

  def [](key)
    instance_variable_get(:"@#{key}")
  end

end
