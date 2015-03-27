module Matterhorn
  class RequestEnv
    extend Forwardable

    def_delegators :options, :[], :[]=, :each, :inspect

    attr_reader :options

    def initialize(options={})
      @options = options
    end

    def ==(other)
      options == other.options
    end

  end
end
