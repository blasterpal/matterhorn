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

require "api_spec"
require "blueprints"
require "class_builder"
require "url_test_helpers"
require "fake_auth"

module BSON
  class ObjectId
    alias :to_json :to_s
    alias :as_json :to_s
  end
end

RSpec.configure do |config|
  config.include ApiSpec, :type => :api

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
