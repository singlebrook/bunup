# Disable coverage by default. When bin/rspec is run (manually or by guard), it
# produces erroneous coverage information. bin/rake produces correct coverage,
# so we'll opt in when using that command.
if ENV['COVERAGE'] == '1'
  require 'simplecov'
  SimpleCov.minimum_coverage 88
  SimpleCov.start do
    add_filter '/spec'
  end
end

require 'byebug'
require 'bunup'
require 'support/helpers'

RSpec.configure do |config|
  config.include Helpers

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
