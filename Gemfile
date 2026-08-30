source "https://rubygems.org"

# Specify your gem's dependencies in auto_strip_attributes.gemspec
gemspec

# Test against a specific Rails minor:  RAILS_VERSION=7.2 bundle install
rails_version = ENV["RAILS_VERSION"]
if rails_version
  gem "rails", "~> #{rails_version}.0"
else
  gem "rails"
end

gem "minitest", "~> 5.25"

