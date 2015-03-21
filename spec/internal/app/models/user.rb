class User
  include Mongoid::Document

  field :name
  field :auth_token

  has_many :posts
  has_many :votes
end
