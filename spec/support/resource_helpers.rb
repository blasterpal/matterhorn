module ResourceHelpers
  extend ActiveSupport::Concern
  include InheritableAccessors::InheritableOptionAccessor

  included do

    inheritable_hash_accessor :resource_methods
    inheritable_hash_accessor :resource_expects

    inheritable_option_accessor \
      :collection_name,
      :resource_class,
      :resource_name,
      :resource_scope,
      for: :resource_methods

  end

  module DSL

    def ie_resource_key_to_match(key,expected_value)
      expect(body[top_level_key][key].execute).to eq(expected_value)
    end

    def its_status_should_be(expected_status)
      resource_expects.merge! status: expected_status
      ie(:status) { expect(status).to eq(resource_expects[:status]) }
    end

    def it_should_have_content_length
      ie(:content_length)  { expect(headers).to have_key("Content-Length") }
    end

    def it_should_create_resource(expected_resource)
      expect(body[top_level_key].execute).to provide(expected_resource)
    end

    def it_should_delete_resource(existing_resource)
      expect(existing_resource).to be_nil
      expect(response.body).to be_empty
    end

    def it_should_have_top_level_data_for_collection
      expect(body[top_level_key].first.execute).to provide(collection.first)
      expect(body[top_level_key].first[:_id].execute).to eq(collection.first.id.to_s)
      expect(body[top_level_key].first[:type].execute).to eq(collection.first.class.name.underscore)
    end

    def it_should_have_top_level_data_for_resource
      # expect(data).to provide(resource)
      expect(data[:_id].execute).to eq(resource.id.to_s)
      expect(data[:type].execute).to eq(resource.class.name.underscore)
    end

    def it_should_respond_with_resource(res=resource)
      expect(body[top_level_key].execute).to provide(res)
    end

    def top_level_key
      Matterhorn::Serialization::TOP_LEVEL_KEY
    end

    def data
      body[top_level_key]
    end

  end

  ClassMethods = DSL
  include DSL
end
