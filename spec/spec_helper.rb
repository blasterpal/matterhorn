require 'rubygems'
require 'bundler/setup'

require 'combustion'

Combustion.initialize! :action_controller

require 'rspec/rails'
require 'serial_spec'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'matterhorn'

RSpec.configure do |config|
  config.include RSpec::Rails::ControllerExampleGroup, :type => :api

  config.define_derived_metadata(:file_path => %r{/spec/api/}) do |metadata|
    metadata[:api] = true
  end
end