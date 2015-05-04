module Matterhorn
  module Paging
    class Default

      # provides a LinkSet or config that can be merged into the request later.  
      # Links should be defined as a type inheriting from SetMember directly, not
      # from the association base class.
      attr_reader :links, :request_env

      # resource    - scope (generally a Mongoid::Criteria)
      # page_params - param.permit(pagination_params)
      def initialize(resource, request_env)
        @object = resource
        @request_env = request_env
      end

      def page_object(object)
        if limit
          object = object.limit(limit)
        end
        if offset
          object = object.offset(offset)
        end
        object
      end

      def limit
        (collection_params[limit_param] || 25).to_i
      end

      def offset
        (collection_params[offset_param]).to_i
      end

      def collection_params
        request_env[:collection_params]
      end

      def limit_param
        self.class.limit_param.to_s
      end

      def offset_param
        self.class.offset_param.to_s
      end

      def self.interfaced(controller)
        controller.pagination_config.set_pagination_class(self)
        controller.allow_collection_params limit_param, offset_param
      end

      def total_objects
        @object.size
      end

      def next_page_params
        {
          offset: limit + offset,
          limit: limit
        }
      end

      def prev_page_params
        params = { limit: limit }
        params[:offset] = offset - limit if offset - limit >= 0
        params
      end

      def first_page_params
        { limit: limit }
      end

      def self.limit_param
        :limit
      end

      def self.offset_param
        :offset
      end

      def link_configs
        {
          next: next_link_config,
          prev: prev_link_config,
          first: first_link_config
        }
      end

      def next_link_config
        Links::LinkConfig.new(nil, :paging, type: :paging, page_params: next_page_params)
      end

      def prev_link_config
        Links::LinkConfig.new(nil, :paging, type: :paging, page_params: prev_page_params)
      end

      def first_link_config
        Links::LinkConfig.new(nil, :paging, type: :paging, page_params: first_page_params)
      end

      def links(link_set_options)
        Links::LinkSet.new(link_configs, link_set_options)
      end

      def ==(other)
        self.class == other.class
      end

    end
  end
end
