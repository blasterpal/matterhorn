require 'inheritable_accessors/inheritable_hash_accessor'

module ResourceHelpers
  extend ActiveSupport::Concern

  included do
    include ResourceHelpers::DSL
    extend  ResourceHelpers::DSL

    inheritable_hash_accessor :resource_methods
    inheritable_hash_accessor :resource_expects
  end

  module DSL
    def resource_class(*obj)
      return resource_methods[:resource_class] if obj.empty?
      resource_methods[:resource_class] = obj.first
    end

    def collection_name(*obj)
      return resource_methods[:collection_name] if obj.empty?
      resource_methods[:collection_name] = obj.first
    end

    def resource_name(*obj)
      return resource_methods[:resource_name] if obj.empty?
      resource_methods[:resource_name] = obj.first
    end

    def resource_scope(*obj)
      return resource_methods[:resource_scope] if obj.empty?
      resource_methods[:resource_scope] = obj.first
    end

    def its_status_should_be(expected_status)
      resource_expects.merge! status: expected_status
      it_expects(:status) { expect(status).to eq(resource_expects[:status]) }
    end

    def it_should_have_content_length
      it_expects(:content_length)  { expect(headers).to have_key("Content-Length") }
    end

  end

end
