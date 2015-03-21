class PostSerializer < BaseSerializer #ActiveModel::Serializer
  attributes :author_id, :body
end
