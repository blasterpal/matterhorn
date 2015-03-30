require 'machinist/mongoid'
require 'securerandom'

Post.blueprint do
  author { User.make! }
end

Vote.blueprint do
  user { User.make! }
  post { Post.make! }
  score { rand(9) }
end

User.blueprint do
  auth_token { SecureRandom.hex }
end
