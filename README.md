# AutoStripAttributes

AutoStripAttributes helps to remove unnecessary whitespaces from ActiveRecord or ActiveModel attributes.
It's good for removing accidental spaces from user inputs (e.g. when user copy/pastes some value and it has extra spaces at the end).

It works by adding a before_validation hook to the record. No other methods are added. Gem is kept as simple as possible.

Gem has option to set empty strings to nil or to remove extra spaces inside the string.

## Howto / examples

Include gem in your Gemfile:

```ruby
gem "auto_strip_attributes"
```

```ruby
class User < ActiveRecord::Base

  # Normal usage where " aaa   bbb\t " changes to "aaa bbb"
  auto_strip_attributes :nick, :comment

  # Squeezes spaces inside the string: "James   Bond  " => "James Bond"
  auto_strip_attributes :name, :squeeze_spaces => true

  # Won't set to null even if string is blank. "   " => ""
  auto_strip_attributes :email, :nullify => false
end
```

## Similar gems

There are many similar gems. Most of those don't have :squeeze_spaces or :nullify options. Those gems
might have some extra methods whereas this gem is kept as simple as possible.

- https://github.com/phatworx/acts_as_strip
- https://github.com/rmm5t/strip_attributes
- https://github.com/thomasfedb/attr_cleaner

# Discussions


