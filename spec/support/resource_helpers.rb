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

    def collection_name(*obj)
      return resource_methods[:collection_name] if obj.empty?
      resource_methods[:collection_name] = obj.first
    end

    def its_status_should_be(expected_status)
      resource_expects.merge! status: expected_status
      it_expects(:status) { expect(status).to eq(resource_expects[:status]) }
    end

    def it_should_have_content_length
      it_expects(:content_length)  { expect(headers).to have_key("Content-Length") }
    end

    def it_should_create_resource(expected_resource)
      expect(body[resource_name].execute).to provide(expected_resource)
    end

    def it_should_delete_resource(existing_resource)
      expect(existing_resource).to be_nil
      expect(response.body).to be_empty
    end

    def it_should_respond_with_resource(res=resource)
      expect(body[resource_name].execute).to provide(res)
    end

    def it_should_respond_with_collection(coll=collection)
      expect(body[collection_name].first.execute).to provide(coll.first)
    end

    def it_expects_resource_key_to_match(key,expected_value)
      expect(body[resource_name][key].execute).to eq(expected_value)
    end

    def resource_class(*obj)
      return resource_methods[:resource_class] if obj.empty?
      resource_methods[:resource_class] = obj.first
    end

    def resource_name(*obj)
      return resource_methods[:resource_name] if obj.empty?
      resource_methods[:resource_name] = obj.first
    end

    def resource_scope(*obj)
      return resource_methods[:resource_scope] if obj.empty?
      resource_methods[:resource_scope] = obj.first
    end

  end

end
