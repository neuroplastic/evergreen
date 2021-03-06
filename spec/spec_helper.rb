require 'rubygems'
require 'bundler/setup'

require 'evergreen'
require 'rspec'

require 'capybara/dsl'
require 'capybara/envjs'

TEST_DRIVER = :envjs

Evergreen.extensions do
  map "/awesome" do
    run lambda { |env| [200, {}, "<html><body>Totally awesome</body></html>"]}
  end
end

Capybara.app = Evergreen::Suite.new(File.expand_path('suite1', File.dirname(__FILE__))).application
Capybara.default_driver = TEST_DRIVER

module EvergreenMatchers
  class PassSpec # :nodoc:
    def matches?(actual)
      @actual = actual
      @runner = Evergreen::Runner.new(actual.suite, StringIO.new).spec_runner(@actual)
      @runner.passed?
    end

    def failure_message
      "expected #{@actual.name} to pass, but it failed with:\n\n#{@runner.failure_messages}"
    end

    def negative_failure_message
      "expected #{@actual.name} not to pass, but it did"
    end
  end

  def pass
    PassSpec.new
  end
end

RSpec.configure do |config|
  config.include EvergreenMatchers
  config.before do
    Evergreen.use_defaults!
    Evergreen.driver = TEST_DRIVER
  end
end
