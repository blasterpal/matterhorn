module Matterhorn
  module Links
    class Association < Matterhorn::Links::SetMember
      
      # interface methods
      def configure_for_relation!
        if belongs_to?(metadata)
          configure_belongs_to!
        elsif has_one?(metadata)
          configure_has_one!
        elsif has_many(metadata)
          configure_has_many!
        elsif scope?(metadata)
          #configure_scope!
        end
      end

      def url_options(resource)
        # look for matterhorn url options here?
        #
        if belongs_to?(metadata)
          belongs_to_url_options(resource)
        elsif has_one?(metadata)
          has_one_url_options(resource)
        elsif has_many(metadata)
          has_many_url_options(resource)
        elsif scope?(metadata)
          scope_url_options(resource)
        end
      end

      def configure_belongs_to!
        @resource_field_key   = metadata.foreign_key.to_sym
        @template_key = ->(resource) { "#{resource_name(context)}.#{resource_field_key}" }
      end

      def configure_has_many!
        @resource_field_key   = config.resource_field_key
        if resource_field_key
          @template_key = ->(resource) { "#{resource_name(context)}.#{resource_field_key}" }
        else
          @template_key = ->(resource) { "#{resource_name(resource)}.#{resource_field_key}" }
        end
      end
        
      def configure_has_one! 
        @resource_field_key   = metadata.primary_key.to_sym
        @template_key = ->(resource) { "#{resource_name(resource)}.#{resource_field_key}" }
        @associated_tense = :singular
      end

      # relation url options methods

      def belongs_to_url_options(resource)
        [template_for(scope_class)]
      end

      def has_many_url_options(resource)
        if resource_field_key
          [template_for(scope_class)]
        else
          [template_for(resource), with_tense(name)]
        end
      end

      def has_many_url_options(resource)
        if resource_field_key
          [template_for(scope_class)]
        else
          [template_for(resource), with_tense(name)]
        end
      end

      def scope_url_options(resource)
        # todo
      end
      
      # relation determination methods
      def belongs_to?(meta)
        meta.metadata && meta.metadata.relation == Mongoid::Relations::Referenced::In
      end

      def has_many?(meta)
        meta.options[:has_many] || meta.metadata && meta.metadata.relation == Mongoid::Relations::Referenced::Many
      end

      def has_one?(meta)
        meta.metadata && meta.metadata.relation == Mongoid::Relations::Referenced::Many and meta.options[:as_singleton]
      end
      
      def scope?(meta)
        #todo
      end

    end
  end
end

