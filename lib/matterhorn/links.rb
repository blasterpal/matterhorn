require "matterhorn/links/link_set"
require "matterhorn/links/set_member"
require "matterhorn/links/association"
require "matterhorn/links/belongs_to"
require "matterhorn/links/has_one"
require "matterhorn/links/has_many"
require "matterhorn/links/link_support"
require "matterhorn/links/link_config"

module Matterhorn
  module Links
    def self.build_link(base_class, name, options={})
      LinkConfig.new(base_class, name, options)
    end
  end
end
