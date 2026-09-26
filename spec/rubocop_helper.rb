require 'rubocop'
require 'rubocop/rspec/support'
require_relative '../lib/rubocop/cop/custom'

RSpec.configure do |config|
  config.include RuboCop::RSpec::ExpectOffense
end
