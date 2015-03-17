class Vote
  include Mongoid::Document

  field :score

  belongs_to :user
  belongs_to :post

end