# Matterhorn [![Build Status](https://travis-ci.org/blakechambers/matterhorn.svg)](https://travis-ci.org/blakechambers/matterhorn)

**NOTICE: this gem is currently under active development at this time. See the [issues][issues] for planned items prior to [0.1.0][milestone]**

Support easy REST API creation and testing that follows the [json-api](http://jsonapi.org/) spec for Rails applications (specifically [rails-api][rails-api]) using MongodDB.  

## Installation and Use

See the [ROADMAP][roadmap] for more info and topics not covered here yet.

### Add to your Gemfile
`gem matterhorn `

### Generate a basic app based on Rails-api

```
rails-api new my_json_api_app
```

### Create your basic resourceful routes

```
Rails.application.routes.draw do
  resources :posts do
    resource  :vote
    resources :comments
  end

  resources :users
  resources :comments
end

```


## Create Controller

### Controller DSL methods and attributes

* `resources!` - Adds actions/methods to controller
* `allow_collection_params` - allows JSON API inclusions and other non-REST attributes to pass 
* `allow_resource_params` - method to set permitted strong parameters.

```
class PostsController < Matterhorn::Base
   include Matterhorn::Resources
   resources! #adds methods
   
   allow_collection_params \
    :include 

   allow_resource_params \ 
     :body, :title, author: [ :id ], topic: [:id, :name]

end
```

### Create your model

#### Model DSL methods and attributes

* `add_inclusion` - sets up up inclusion for a model, can optionally be passed a `:scope`
* `add_link` - sets up links returned in response and how they are related to this model. (MORE INFO NEEDED)

```
class Post
  include Mongoid::Document
  include Matterhorn::Inclusions::InclusionSupport
  include Matterhorn::Links::LinkSupport

  field :title
  field :body
  field :initial_comments_ids, type: Array

  belongs_to :author, class_name: "User"
  add_inclusion :author

  has_many :votes
  has_many :comments

  scope = proc do |set_member, env|
    env[:current_user].votes.all
  end

  add_inclusion :votes, scope: scope, as_singleton: true
  add_inclusion :comments, scope: scope

  #validates_presence_of :author
  validates_presence_of :body
  validates_presence_of :title

  accepts_nested_attributes_for :author

  add_link      :comments, as: :initial_comments, 
                resource_field: :initial_comments_ids, 
                scope_class: Comment, has_many: true

end
```

### [Resource Scopes](#resource-scopes)
 
* `collection_scope`
* `resource_scope`
 
### [Inclusions](#inclusions)

### [Links](#links)

### [Strong parameters](#strong-params)

* `permitted_params`

### [Multi-id Resources](#multi-id-resources)

* `/posts/id1,id3/comments.json`

### [Singleton Resources](#singleton-resources)

## Contributing

1. Fork it ( https://github.com/blakechambers/matterhorn/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[issues]:    https://github.com/blakechambers/matterhorn/issues
[milestone]: https://github.com/blakechambers/matterhorn/milestones/0.1.0%20-%20Initial%20release
[roadmap]:   https://github.com/blakechambers/matterhorn/blob/master/ROADMAP.md
[rails-api]: https://github.com/rails-api/rails-api
