require "active_support/concern"
require "active_model_serializers"

# yikes, temporary
# class ActiveModel::Serializer
#   def self.build_json(controller, resource, options)
#     options[:url_options]       = controller.url_options
#     options[:collection_params] = controller.send(:collection_params)
#
#     serializer = resource.kind_of?(Enumerable) ? Matterhorn::Serialization::ScopedCollectionSerializer : Matterhorn::Serialization::ScopedResourceSerializer
#     ser = serializer.new(resource, options)
#   end
# end

require "inheritable_accessors"
require "matterhorn/version"
require "matterhorn/serialization"
require "matterhorn/inclusion"
require "matterhorn/controller/api"
require "matterhorn/resources"

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

ActiveModel::Serializer.send :prepend, Matterhorn::Serialization::BuilderSupport
