require "inheritable_accessors/inheritable_set_accessor"
require "matterhorn/inclusions/inclusion_support"

module Matterhorn

  module ErrorHandling
    extend ActiveSupport::Concern

    included do
      rescue_from "ActionController::ActionControllerError", with: :handle_controller_error
    end

  protected ####################################################################

    def handle_controller_error(error)
      puts "Request Error: #{error}" 
      error = Matterhorn::ResourceError.new(error)
      render error.to_response_options
    end
  end

  module Resources
    extend ActiveSupport::Concern
    include InheritableAccessors::InheritableSetAccessor
    include Matterhorn::Inclusions::InclusionSupport
    include ErrorHandling

    ACTIONS = [:index, :show, :create, :update, :destroy]

    included do
      self.respond_to :json
      self.responder = ::Matterhorn::Responder

      helper_method :collection, :resource, :collection_params, :resource_params
      attr_reader   :scope

      inheritable_set_accessor :allowed_collection_params
      inheritable_set_accessor :allowed_write_params
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
        with_scope(write_resource_scope) do
          set_resource collection.create(resource_write_params)
          respond_with resource, {status: 201 }
        end
      end
    END_OF_CREATE_METHOD

    update_action = <<-END_OF_UPDATE_METHOD
      def update
        with_scope(write_resource_scope) do
          resource.update_attributes(resource_write_params)
          respond_with resource
        end
      end
    END_OF_UPDATE_METHOD

    destroy_action = <<-END_OF_DESTROY_METHOD
      def destroy
        with_scope(write_resource_scope) do
          resource.destroy
          head status: 204
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

      def add_env(name)
        serialization_env_names << name.to_sym
      end

      def allow_collection_params(*params)
        allowed_collection_params.merge params.flatten
      end

      def allow_write_params(*params)
        allowed_write_params.merge params.flatten
      end

    end

  protected ######################################################################

    def collection_params
      params.permit(self.class.allowed_collection_params.to_a)
    end

    def collection_or_multi_id_collection
      if multi_ids_request?
        selector = {multi_id_key => multi_ids}
        set_collection(resource_class.in(selector))
      else
        collection
      end
    end

    def multi_ids
      params[multi_id_key].split(',')
    end
     
    #TODO  This method needs review
    def multi_id_key
      key = :id
      if parent?
        key = resources_configuration[symbols_for_association_chain.first][:param]
      end
      key
    end

    def multi_ids_request?
      params[multi_id_key] && params[multi_id_key].include?(',')
    end

    def read_collection_scope
      collection
    end
    
    def read_resource_scope
      resource
    end

    def resource_action
      action_name.to_sym
    end

    def resource_name
      self.class.controller_name.singularize
    end

    def resource_class
      resource_name.camelize.safe_constantize
    end

    def resource_scope
      resource_class.all
    end

    def resource_params
      params.require(resource_name)
    end

    def resource_write_params
      params.require(resource_name).permit(self.class.allowed_write_params.to_a)
    end

    def resource_or_multi_id_collection
      if multi_ids_request?
        set_resource(resource_class.in(id: multi_ids))
      else
        resource
      end
    end
    
    def set_collection(coll)
      set_collection_ivar(coll)
    end 
    def set_resource(res)
      set_resource_ivar(res)
    end

    def write_resource_scope
      resource_scope.all
    end

    def with_scope(scope)
      @scope = scope
      yield(scope)
      @scope = nil
    end

  end
end
