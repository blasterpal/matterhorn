require "matterhorn/links/link_set"
require "matterhorn/links/set_member"
require "matterhorn/links/relation/base"
require "matterhorn/links/relation/belongs_to"
require "matterhorn/links/relation/has_one"
require "matterhorn/links/relation/has_many"
require "matterhorn/links/link_support"
require "matterhorn/links/link_config"

module Matterhorn
  module Links

    class ConfigurationError < StandardError ; end

    def self.build_link(base_class, name, options={})
      config = LinkConfig.new(base_class, name, options)
      type = determine_link_type(config)

      config.type = type
      config
    end

    def self.types
      @types ||= Hash.new
    end

    def self.add_link_type(type_name, klass)
      types[type_name] = klass if link_class_valid?(type_name, klass)
    end

    def self.determine_link_type(link_config)
      matching_pair = types.detect do |link_name, link_class|
        link_class.is_valid_config?(link_config)
        link_class.is_valid_config?(link_config)
      end

      raise(StandardError, "could not find type for link: #{self.inspect}") if matching_pair.nil?
      matching_pair.first
    end

    def self.link_class_for_type(type_name)
      matching_pair = types.detect do |link_name, link_class|
        link_name == type_name
      end

      raise(StandardError, "could not find type for link: #{self.inspect}") if matching_pair.nil?
      matching_pair.last
    end

    def self.link_class_valid?(type_name, klass)
      true
    end

    add_link_type :belongs_to, Relation::BelongsTo
    add_link_type :has_one,    Relation::HasOne
    add_link_type :has_many,   Relation::HasMany

    # def self.valid_types
    #   @valid_types ||= begin
    #     types = Hash.new
    #     types[Mongoid::Relations::Referenced::In]   = :belongs_to
    #     types[Mongoid::Relations::Referenced::Many] = :has_many
    #     types[Mongoid::Relations::Referenced::One]  = :has_one
    #
    #     types
    #   end
    # end
    #
    # def infer_type!
    #   if metadata
    #     @type = LinkConfig.valid_types[metadata.relation]
    #   elsif false
    #     # named scopes, etc
    #   end
    #
    #   raise(StandardError, "could not find type for link: #{self.inspect}") unless @type
    # end



  end
end
