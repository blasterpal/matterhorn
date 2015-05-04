require "matterhorn/serialization/builder_support"
require "matterhorn/serialization/scoped"
require "matterhorn/serialization/scoped_collection_serializer"
require "matterhorn/serialization/scoped_resource_serializer"
require "matterhorn/serialization/error_serializer"
require "matterhorn/url_helper"
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

      def object_link_config
        object.respond_to?(:__link_configs) ? object.__link_configs : Hash.new
      end

      def links
        link_set_options = { context: object, request_env: request_env }
        model_links = Links::LinkSet.new(object_link_config, link_set_options)
        self_config= Links::LinkConfig.new(nil, :self, type: :self)
        self_links = Links::LinkSet.new({self: self_config}, link_set_options)

        model_links.merge!(self_links.config)
        
        if options[:inclusion]
          model_links.set_inclusion
        end

        link_set_serializer = LinkSetSerializer.new(model_links, context: object)
        link_set_serializer.serializable_hash
      end

      def request_env
        @options[:request_env]
      end

    end

    class InclusionSerializer < ActiveModel::Serializer
      attribute :name
    end

    class LinkSetSerializer
      attr_reader :link_set, :options, :context

      # object - a LinkSet instance
      # context - the thing you are serializing
      def initialize(link_set, options={})
        @link_set, @options = link_set, options
        @context = options[:context]
      end

      def serializable_hash
        link_set.inject(Hash.new) do |sum, pair|
          name, set_member = *pair

          sum[name] = set_member.serialize(context)
          sum
        end
      end
    end

    class URITemplate < ::Matterhorn::UrlHelper::FauxResource

      def to_param
        "{#{param}}"
      end

      def self.for(obj, param)
        build_for(obj).new(obj, param)
      end

      def self.build_for(obj)
        Class.new(URITemplate).tap do |klass|
          klass.module_eval <<-METHOD
            def self.name
              "#{Matterhorn::Serialization.classify_name(obj).name}"
            end
          METHOD
        end
      end

    end

    def self.classify_name(obj)
      case obj
      when Mongoid::Criteria then obj.klass
      when Mongoid::Document then obj.class
      when Class             then obj
      else
        raise ArgumentError, "unable to classify: #{obj.inspect}"
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
