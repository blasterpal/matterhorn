require 'machinist/mongoid'
require 'securerandom'

Post.blueprint do
  author  { User.make! }
  title   { Faker::Lorem.sentence(2) }
  body    {  Faker::Lorem.sentence(4)}
  topic   { Topic.make! }
end

Topic.blueprint do
  name    {Faker::Lorem.word}
end

Comment.blueprint do
  user  { User.make! }
  post  { Post.make! }
  text  {  Faker::Lorem.sentence(4)}
end

User.blueprint do
  auth_token  { SecureRandom.hex }
  name        { Faker::Name.name }
end

Vote.blueprint do
  user  { User.make! }
  post  { Post.make! }
  score { rand(9) }
end

