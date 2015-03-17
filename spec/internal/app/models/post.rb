class Post
  include Mongoid::Document
  include Matterhorn::Inclusions::InclusionSupport

  field :body
  belongs_to :author, class_name: "User"
  add_inclusion :author

  has_many :votes
end