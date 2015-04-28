module Matterhorn
  module Serialization
    module Scoped
      module LinkSupport

        def serializable_hash
          merge_links! super()
        end

      protected ################################################################

        def merge_links!(hash)
          link_set_options = { context: object, request_env: request_env }
          model_links = Links::LinkSet.new(object.__link_configs, link_set_options)
          self_config = Links::LinkConfig.new(nil, :self, type: :self)
          self_links  = Links::LinkSet.new({self: self_config}, link_set_options)

          model_links.merge!(self_links.config)

          criteria = object.kind_of?(Mongoid::Document) ? object.class.where(id: object._id) : object
          link_set_serializer = LinkSetSerializer.new(model_links, context: criteria)

          hash["links"] = link_set_serializer.serializable_hash
          hash
        end

      end
    end
  end
end
