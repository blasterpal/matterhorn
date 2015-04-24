module Matterhorn
  module UrlHelper
    class FauxResource
      extend ActiveModel::Naming

      class_attribute :_templates
      self._templates = {}

      attr_reader :param

      def initialize(obj, param)
        @obj   = obj
        @param = param
      end

      def to_param
        "#{param}"
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
        Class.new(FauxResource).tap do |klass|
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
  end
end
