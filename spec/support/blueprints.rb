require 'machinist/mongoid'

Post.blueprint do
  author  { User.make! }
  body    { "body" }
  # title   { "title" }
  topic   { Topic.make! }
end

Topic.blueprint do
  name    { "name" }
end

Comment.blueprint do
  user  { User.make! }
  post  { Post.make! }
  text  { "comment" }
end

User.blueprint do
  auth_token  { "token" }
  name        { "name" }
end

Vote.blueprint do
  user  { User.make! }
  post  { Post.make! }
  score { 1 }
end
