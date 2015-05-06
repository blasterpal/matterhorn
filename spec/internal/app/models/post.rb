class Post
  include Mongoid::Document
  include Mongoid::Timestamps
  include Matterhorn::Links::LinkSupport

  field :title
  field :body
  field :initial_comments_ids, type: Array

  belongs_to :author, class_name: "User"

  has_and_belongs_to_many :topics, inverse_of: nil

  has_many :comments
  has_one  :topic
  has_many :votes

  vote_scope = proc do |scope_class, set_member, env|
    env[:current_user].votes.all
  end

  add_link :topics,
    nested:         true

  add_link :author

  add_link :vote,
    relation_name:  :votes,
    singleton:      true,
    scope:          vote_scope,
    nested:         true,
    type:           :has_one

  add_link :comments,
    nested:         true

  validates_presence_of :body

  accepts_nested_attributes_for :author, :topic

end
