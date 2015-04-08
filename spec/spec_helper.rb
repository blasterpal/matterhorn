require 'rubygems'
require 'bundler/setup'

require 'combustion'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "matterhorn/reject_links_middleware"
Combustion.initialize! :action_controller do
  config.middleware.use Matterhorn::RejectLinksMiddleware
end

require 'rspec/rails'
require 'serial_spec'
require 'inheritable_accessors'
require 'mongoid'
require 'database_cleaner'

require 'matterhorn'

Mongoid.load!("spec/internal/config/mongoid.yml", :test)

$LOAD_PATH.unshift File.expand_path('../../spec/support', __FILE__)

require "api_spec"
require "authentication_helpers"
require "blueprints"
require "class_builder"
require "url_test_helpers"
require "fake_auth"

module BSON
  class ObjectId
    def as_json(opts=nil)
      to_s
    end
    alias :to_json :as_json
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
