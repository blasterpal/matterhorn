class PostSerializer < BaseSerializer #ActiveModel::Serializer
  attributes :author_id, :body, :initial_comments_ids
end
