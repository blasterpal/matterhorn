require "inherited_resources/singleton_helpers"
require "inheritable_accessors/inheritable_set_accessor"
require "matterhorn/inclusions/inclusion_support"
require "matterhorn/error_handling"
require "matterhorn/resource_helpers"

module Matterhorn
  module Resource
    extend ActiveSupport::Concern
    include InheritedResources::SingletonHelpers
    include InheritableAccessors::InheritableSetAccessor
    include Matterhorn::Inclusions::InclusionSupport
    include ErrorHandling
    include ResourceHelpers

    ACTIONS = [:show, :create, :update, :destroy] #no index here
    
    def  build_resource(attributes = {})
      resource_class.new(attributes)  
    end

    included do

      defaults :singleton => true

      self.respond_to :json
      self.responder = ::Matterhorn::Responder

      helper_method :collection, :resource, :collection_params, :resource_params
      attr_reader   :scope

      inheritable_set_accessor :allowed_collection_params
      inheritable_set_accessor :allowed_resource_params
      inheritable_set_accessor :serialization_env_names

    end

    def self.extract_actions(options)
      raise ArgumentError, "cannot use both :only and :except to configure" if options[:only] and options[:except]

      actions = ACTIONS
      actions = options[:only] if options[:only]
      actions = actions - options[:except] if options[:except]
      actions
    end

    index_action = <<-END_OF_INDEX_METHOD
      def index
        with_scope(collection_or_multi_id_collection) do
          respond_with collection
        end
      end
    END_OF_INDEX_METHOD

    show_action = <<-END_OF_SHOW_METHOD
      def show
        with_scope(resource_or_multi_id_collection) do
          respond_with resource
        end
      end
    END_OF_SHOW_METHOD

    create_action = <<-END_OF_CREATE_METHOD
      def create
        with_scope(resource_scope) do
          set_resource scope.create(permitted_params)
          respond_with resource, {status: 201 }
        end
      end
    END_OF_CREATE_METHOD

    update_action = <<-END_OF_UPDATE_METHOD
      def update
        with_scope(collection_scope) do
          scope.update_attributes(permitted_params)
          respond_with resource
        end
      end
    END_OF_UPDATE_METHOD

    destroy_action = <<-END_OF_DESTROY_METHOD
      def destroy
        with_scope(resource_scope) do
          scope.destroy
          head status: 204
        end
      end
    END_OF_DESTROY_METHOD

    ACTION_METHODS = {
      show:    show_action,
      create:  create_action,
      update:  update_action,
      destroy: destroy_action
    }

    module ClassMethods
      def resource!(options={})
        action_names = Resource.extract_actions(options)
        action_blob = ACTION_METHODS.map do |name, methud|
          action_names.include?(name) ? methud : nil
        end.compact.join("\n")

        module_eval <<-MODULE_EVAL, __FILE__, __LINE__
          #{action_blob}
        MODULE_EVAL
      end
      
    end
  end
end
