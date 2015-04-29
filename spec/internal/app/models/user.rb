class User
  include Mongoid::Document

  field :name
  field :auth_token

  has_many :posts
  has_many :votes

  validates_presence_of :name

end
