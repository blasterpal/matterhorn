module Matterhorn
  module SpecHelpers
    module Resourceful
      module CollectionBehaviors
        extend ActiveSupport::Concern
        include ResourceHelpers

        included do

          with_request "GET /#{collection_name}.json" do
            its_status_should_be 200
            it_should_have_content_length

            it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
            it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
            it_expects(:collection_body) { expect(body[collection_name]).to be_an(Array) }

            it "should provide items with existing resources" do
              resource_class.make!

              perform_request!

              expect(body[collection_name].count).to eq(1)
            end

            it "should provide links object in response"
            it "should provide meta object"
            it "should list provided inclusions"
            it "should return self link option"
            it "should reject invalid accept types" do
              # rails will take the extension first.
              request_path "/#{collection_name}"

              request_envs.merge! "HTTP_ACCEPT" => "invalid/format"

              its_status_should_be 406
              it_expects(:collection_body) { :remove_this }
              it_expects(:error_body) {
                expect(body["error"]).to_not eq({"error"=>"ActionController::UnknownFormat"}) }

              perform_request!
            end
            it "should provide next"
          end
        end
      end
    end
  end
end