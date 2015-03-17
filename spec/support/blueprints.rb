require 'machinist/mongoid'

Post.blueprint do
  author { User.make }
end

Vote.blueprint do
  user { User.make }
  post { Post.make }
end

User.blueprint do
end