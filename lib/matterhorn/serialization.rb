require "matterhorn/serialization/builder_support"
require "matterhorn/serialization/scoped"
require "matterhorn/serialization/scoped_collection_serializer"
require "matterhorn/serialization/scoped_resource_serializer"
require "matterhorn/serialization/error_serializer"
require "cgi"

module Matterhorn
  module Serialization

    TOP_LEVEL_KEY = :data

    module SerializationSupport
      extend ActiveSupport::Concern
      included do
        attributes :_id, :type
      end

      def type
        object.class.name.underscore
      end

      module ClassMethods

        def configure_matterhorn
          # do nothing for now.
        end

      end
    end

    class BaseSerializer < ActiveModel::Serializer
      include SerializationSupport

      attributes :links

      configure_matterhorn

    protected ##################################################################

      def include_links?
        !url_builder.blank?
      end

      def links
        result = object.links.build_linkage(url_builder, self)
        result[:self] = url_builder.url_for(object.try(:matterhorn_url_options) || object)
        result
      end

      def url_builder
        @url_builder ||= @options[:url_builder]
      end

    end

    class InclusionSerializer < ActiveModel::Serializer
      attribute :name
    end

    class URITemplate
      extend ActiveModel::Naming

      class_attribute :_templates
      self._templates = {}

      attr_reader :param

      def initialize(obj, param)
        @obj   = obj
        @param = param
      end

      def to_param
        "{#{param}}"
      end

      def persisted?
        true
      end

      def to_model
        self
      end

      def self.for(obj, param)
        build_for(obj).new(obj, param)
      end

      def self.build_for(obj)
        Class.new(URITemplate).tap do |klass|
          klass.module_eval <<-METHOD
            def self.name
              "#{classify_name(obj).name}"
            end
          METHOD
        end
      end
      
      # will this consider scopes and paging?
      def self.classify_name(obj)
        case obj
        when Mongoid::Criteria then obj.klass
        when Mongoid::Document then obj.class
        when Class             then obj
        else
          raise ArgumentError, "unable to classify: #{obj.inspect}"
        end
      end

    end

    class UrlBuilder

      def initialize(options={})
        self.default_url_options = options[:url_options]
      end

      def url_for(*args)
        CGI.unescape(super(*args))
      end

      def ==(other)
        other.default_url_options == default_url_options
      end

    end

  end
end
