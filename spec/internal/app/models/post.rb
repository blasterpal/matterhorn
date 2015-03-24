class Post
  include Mongoid::Document
  include Matterhorn::Inclusions::InclusionSupport

  field :body

  belongs_to :author, class_name: "User"
  add_inclusion :author

  has_many :votes

  scope = proc do |set_member, env|
    env[:current_user].votes.all
  end

  add_inclusion :votes, scope: scope
end
