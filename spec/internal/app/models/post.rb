class Post
  include Mongoid::Document
  include Matterhorn::Inclusion::InclusionSupport

  field :body
  belongs_to :author, class_name: "User"
  add_inclusion :author
end