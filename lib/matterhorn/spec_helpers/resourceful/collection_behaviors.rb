RSpec.shared_examples "GET /:collection_name" do |options|
  collection_name = options[:collection_name]
  resource_class  = options[:resource_class]

  it_expects(:status)          { expect(status).to eq(200) }
  it_expects(:content_type)    { expect(headers["Content-Type"]).to include("application/json") }
  it_expects(:utf8)            { expect(headers["Content-Type"]).to include("charset=utf-8") }
  it_expects(:content_length)  { expect(headers).to have_key("Content-Length") }
  it_expects(:collection_body) { expect(body[collection_name]).to be_an(Array) }

  with_request "GET /#{collection_name}" do
    let!(:existing_resources) { self.class.resource_class.make! }

    it_expects(:collection_size) { expect(body[collection_name].count).to eq(1) }
  end

end