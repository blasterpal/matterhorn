class User
  include Mongoid::Document

  field :name

  has_many :posts
  has_many :votes
end