class Comment
  include Mongoid::Document
  include Matterhorn::Inclusions::InclusionSupport

  field :text

  belongs_to :user
  belongs_to :post

end
