class Topic
  include Mongoid::Document
  include Matterhorn::Inclusions::InclusionSupport

  field :name

  belongs_to :post

  validates_presence_of :name

  def matterhorn_url_options
    [post, 'topic']
  end

end
