require "inheritable_accessors/inheritable_set_accessor"
require "matterhorn/inclusions/inclusion_support"

module Matterhorn
  module Resources
    extend ActiveSupport::Concern
    include InheritableAccessors::InheritableSetAccessor
    include Matterhorn::Inclusions::InclusionSupport

    ACTIONS = [:index, :show, :create, :update, :destroy]

    included do
      helper_method :collection, :resource, :collection_params, :resource_params
      attr_reader   :scope

      inheritable_set_accessor :allowed_collection_params
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
        with_scope(read_resource_scope) do
          respond_with collection
        end
      end
    END_OF_INDEX_METHOD

    show_action = <<-END_OF_SHOW_METHOD
      def show
        with_scope(read_resource_scope) do
          respond_with resource
        end
      end
    END_OF_SHOW_METHOD

    create_action = <<-END_OF_CREATE_METHOD
      def create
        with_scope(write_resource_scope) do
          set_resource collection.create(resource_params)

          respond_with resource
        end
      end
    END_OF_CREATE_METHOD

    update_action = <<-END_OF_UPDATE_METHOD
      def update
        with_scope(write_resource_scope) do
          resource.update_attributes(resource_params)
          respond_with resource
        end
      end
    END_OF_UPDATE_METHOD

    destroy_action = <<-END_OF_DESTROY_METHOD
      def destroy
        with_scope(write_resource_scope) do
          resource.destroy
          respond_with resource
        end
      end
    END_OF_DESTROY_METHOD

    ACTION_METHODS = {
      index:   index_action,
      show:    show_action,
      create:  create_action,
      update:  update_action,
      destroy: destroy_action
    }

    module ClassMethods
      def resources!(options={})
        action_names = Resources.extract_actions(options)
        action_blob = ACTION_METHODS.map do |name, methud|
          action_names.include?(name) ? methud : nil
        end.compact.join("\n")

        module_eval <<-MODULE_EVAL, __FILE__, __LINE__
          #{action_blob}
        MODULE_EVAL
      end

      def allow_collection_params(*params)
        allowed_collection_params.merge params.flatten
      end
    end

  protected ######################################################################

    def resource_name
      self.class.controller_name.singularize
    end

    def resource_class
      resource_name.camelize.safe_constantize
    end

    def resource_scope
      resource_class.all
    end

    def read_resource_scope
      resource_scope.all
    end

    def write_resource_scope
      resource_scope.all
    end

    def with_scope(scope)
      @scope = scope
      yield(scope)
      @scope = nil
    end

    def collection
      @collection ||= scope.all
    end

    def resource
      @resource ||= scope.find(params[:id])
    end

    def set_resource(res)
      @resource = res
    end

    def resource_params
      params.require(resource_name)
    end

    def collection_params
      params.permit(self.class.allowed_collection_params.to_a)
    end

  end
end