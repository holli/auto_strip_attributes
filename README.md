# AutoStripAttributes

AutoStripAttributes helps to remove unnecessary whitespaces from ActiveRecord or ActiveModel attributes.
It's good for removing accidental spaces from user inputs.

It works by adding a before_validation hook to the record. It has option to set empty strings to nil or
to remove extra spaces inside the string.

## Howto / examples

Include gem in your Gemfile:

```ruby
gem "auto_strip_attributes"
```

```ruby
class User < ActiveRecord::Base

  # Normal usage where " aaa   bbb\t " changes to "aaa bbb"
  auto_strip_attributes :nick, :comment

  # "James   Bond  " => "James Bond"
  auto_strip_attributes :name, :squeeze_spaces => true

  # "   " => "", won't set to null if blank
  auto_strip_attributes :email, :nullify => false
end
```

## Similar gems

- https://github.com/phatworx/acts_as_strip
- https://github.com/rmm5t/strip_attributes
- https://github.com/thomasfedb/attr_cleaner

# Discussions


