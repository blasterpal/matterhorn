class Vote
  include Mongoid::Document
  include Matterhorn::Inclusions::InclusionSupport

  field :score

  belongs_to :user
  belongs_to :post


  validates_presence_of :score
  validates_numericality_of :score

  def matterhorn_url_options
    [post, 'vote']
  end

end
