require "active_support/concern"
require "active_model_serializers"

require "matterhorn/version"
require "matterhorn/serialization"
require "matterhorn/inclusion"
require "matterhorn/controller/api"

module Matterhorn
  # Your code goes here...
end

if defined?(Rails)
  module Matterhorn
    class Railtie < Rails::Railtie
      initializer "serialization.matterhorn" do |app|
      end
    end
  end
end

ActiveModel::Serializer.send :extend, Matterhorn::Serialization::BuilderSupport