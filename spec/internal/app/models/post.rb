class Post
  include Mongoid::Document
  include Matterhorn::Inclusions::InclusionSupport
  include Matterhorn::Links::LinkSupport

  field :title
  field :body
  field :initial_comments_ids, type: Array

  belongs_to :author, class_name: "User"
  add_inclusion :author

  has_many :votes
  has_many :comments
  has_one  :topic

  scope = proc do |set_member, env|
    env[:current_user].votes.all
  end

  add_inclusion :votes,
    scope:        scope,
    as_singleton: true

  add_inclusion :comments,
    scope: scope

  add_link :comments,
    as:               :initial_comments,
    resource_field:   :initial_comments_ids,
    scope_class:      Comment,
    has_many:         true

  validates_presence_of :body
  validates_presence_of :title

  accepts_nested_attributes_for :author, :topic

end
