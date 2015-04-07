class Topic
  include Mongoid::Document
  include Matterhorn::Inclusions::InclusionSupport

  field :name

  belongs_to :post

  validates_presence_of :name

  # Use this method to override the url_for on this nested,singleton resource. 
  # The below return will be handed as-is to ActionDispatch::Routing::UrlFor
  def matterhorn_url_options
    [post, 'topic']
  end

end
