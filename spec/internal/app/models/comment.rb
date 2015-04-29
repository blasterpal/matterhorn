class Comment
  include Mongoid::Document
  include Matterhorn::Links::LinkSupport

  field :text

  belongs_to :user
  belongs_to :post

  add_link :post

end
