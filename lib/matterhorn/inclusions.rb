require "matterhorn/inclusions/inclusions_config"
require "matterhorn/inclusions/inclusion_set"
require "matterhorn/inclusions/set_member"
require "matterhorn/inclusions/inclusion_support"

module Matterhorn
  module Inclusions

    def self.build_inclusion(base_class, name, options={})
      InclusionConfig.new(base_class, name, options)
    end

  end
end
