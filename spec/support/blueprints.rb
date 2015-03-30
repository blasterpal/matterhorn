require 'machinist/mongoid'
require 'securerandom'

Post.blueprint do
  author  { User.make! }
  title   { Faker::Lorem.sentence(2) }
  body    {  Faker::Lorem.sentence(4)}
end

Vote.blueprint do
  user  { User.make! }
  post  { Post.make! }
  score { rand(9) }
end

User.blueprint do
  auth_token  { SecureRandom.hex }
  name        { Faker::Name.name }
end
