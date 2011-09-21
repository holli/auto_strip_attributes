# AutoStripAttributes

AutoStripAttributes helps to remove unnecessary whitespaces from ActiveRecord or ActiveModel attributes.
It's good for removing accidental spaces from user inputs (e.g. when user copy/pastes some value to a form and the value has extra spaces at the end).

It works by adding a before_validation hook to the record. No other methods are added. Gem is kept as simple as possible.

Gem has option to set empty strings to nil or to remove extra spaces inside the string.

## Howto / examples

Include gem in your Gemfile:

```ruby
gem "auto_strip_attributes", "~> 1.0"
```

```ruby
class User < ActiveRecord::Base

  # Normal usage where " aaa   bbb\t " changes to "aaa bbb"
  auto_strip_attributes :nick, :comment

  # Squeezes spaces inside the string: "James   Bond  " => "James Bond"
  auto_strip_attributes :name, :squish => true

  # Won't set to null even if string is blank. "   " => ""
  auto_strip_attributes :email, :nullify => false
end
```

# Requirements

Gem has been tested with ruby 1.8.7, 1.9.2 and Rails 3.x. Although it should also work with previous versions of rails.

http://travis-ci.org/#!/holli/auto_strip_attributes

# Support

Submit suggestions or feature requests as a GitHub Issue or Pull Request. Remember to update tests. Tests are quite extensive.

# Other approaches

This gem works by addin before_validation hook and setting attributes with self[attribute]=stripped_value. See: https://github.com/holli/auto_strip_attributes/blob/master/lib/auto_strip_attributes.rb

Other approaches could include calling attribute= from before_validation. This would end up calling possible custom setters twice. Might not be desired effect (e.g. if setter does some logging).

Method chaining attribute= can be also used. But then stripping would be omitted if there is some code that calls model[attribute]= directly. This could happen easily when using hashes in some places.

## Similar gems

There are many similar gems. Most of those don't have :squish or :nullify options. Those gems
might have some extra methods whereas this gem is kept as simple as possible. These gems have a bit
different approaches. See discussion in previous chapter.

- https://github.com/phatworx/acts_as_strip
- https://github.com/rmm5t/strip_attributes
- https://github.com/thomasfedb/attr_cleaner
- https://github.com/mdeering/attribute_normalizer (Bit hardcore approach, more features and more complex)

# Licence

Released under the MIT license (http://www.opensource.org/licenses/mit-license.php)

