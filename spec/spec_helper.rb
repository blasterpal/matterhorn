require 'rubygems'
require 'bundler/setup'

require 'combustion'

Combustion.initialize! :action_controller

require 'rspec/rails'
require 'serial_spec'
require 'mongoid'
require 'database_cleaner'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'matterhorn'
require 'matterhorn/spec_helpers'

Mongoid.load!("spec/internal/config/mongoid.yml", :test)

require File.expand_path("../../spec/support/api_spec", __FILE__)
require File.expand_path("../../spec/support/blueprints", __FILE__)

RSpec.configure do |config|
  config.include ApiSpec, :type => :api

  config.define_derived_metadata(:file_path => %r{/spec/resources_api/}) do |metadata|
    metadata[:type] = :api
  end

  config.before(:all) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end
end