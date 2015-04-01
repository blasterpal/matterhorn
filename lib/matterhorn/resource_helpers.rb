module Matterhorn
  module ResourceHelpers

    def add_env(name)
      serialization_env_names << name.to_sym
    end

    def allow_collection_params(*params)
      allowed_collection_params.merge params.flatten
    end

    def allow_write_params(*params)
      allowed_write_params.merge params.flatten
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
