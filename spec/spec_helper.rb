require 'rubygems'
require 'bundler/setup'

require 'combustion'

Combustion.initialize! :action_controller

require 'rspec/rails'
require 'serial_spec'
require 'inheritable_accessors'
require 'mongoid'
require 'database_cleaner'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'matterhorn'

Mongoid.load!("spec/internal/config/mongoid.yml", :test)

$LOAD_PATH.unshift File.expand_path('../../spec/support', __FILE__)

require "blueprints"

require "resource_helpers"
require "class_builder"
require "url_test_helpers"
require "api_example_set"
require "fake_auth"
require "authentication_helpers"

module SerialSpec::ItExpects::DSL
  alias :ie :it_expects
end

module BSON
  class ObjectId
    def as_json(opts=nil)
      to_s
    end
    alias :to_json :as_json
  end
end

RSpec.configure do |config|
  config.include ApiExampleSet, :type => :api

  config.define_derived_metadata(:file_path => %r{/spec/resources_api/}) do |metadata|
    metadata[:type] = :api
  end

  config.before(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end

end
