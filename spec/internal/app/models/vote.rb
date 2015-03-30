class Vote
  include Mongoid::Document
  include Matterhorn::Inclusions::InclusionSupport

  field :score

  belongs_to :user
  belongs_to :post

end
