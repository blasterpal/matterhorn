Current issues with links

- there isn't a good reason to define links using add_link in models other than inclusions.  the syntax seems unnecessary.
- what happens when you add_link to thing that is not a relationship
- type is added to link_config, as the set_member name.
- `as` option is redundant, should infer from association.
- `metadata`, `scope_class`, and `resource_field_key` is specific to associations, should be moved to parent associations subclass
- Set member classes must define an `includable?` method to allow them to be added as inclusions during request.

TODO LIST:

- [ ] association class changes
- [ ] link_config rewrite
- [ ] visit set_member

-----

``` ruby
class Post
  include Mongoid::Document
  include Matterhorn::Inclusions::InclusionSupport
  include Matterhorn::Links::LinkSupport

  belongs_to :author, class_name: "User"

  # posts form the last 24 hours.
  add_scope :recent, -> { where(:created_at.gte => 24.hours.ago ) }

  # this should be inferred without explicitly calling.
  # add_link   :author , type: Matterhorn::Links::Relation::BelongsTo
  add_link   :author

  # this should be inferred without explicitly calling.
  # add_link :recent, type: Matterhorn::Links::Filter
  add_link :recent


  relations[:author] => metadata
  relations[:recent] => nil

  self.author returns a model
  self.recent returns a scope

  has_many :votes

  scope = proc do |set_member, env|
    env[:current_user].votes.all
  end

  add_inclusion :votes,
    scope:        scope,
    as_singleton: true

end
```

## LinkConfig components

attr_reader :type
attr_reader :base
attr_reader :name
attr_reader :options
  relation_name: :votes,
  scope:         scope,
  nested:        true,
  singleton:     true,
  type:          linkset class


## Dealing with singletons

Example:

```ruby
class Post
  include Mongoid::Document
  include Matterhorn::Inclusions::InclusionSupport
  include Matterhorn::Links::LinkSupport

  has_many :votes

  scope = proc do |set_member, env|
    env[:current_user].votes.all
  end

  add_link :my_vote,
    relation_name: :votes,
    scope:         scope,
    nested:        true,
    singleton:     true

  def self.matterhorn_url_options(obj)
    [obj]
  end
end
```

The possible urls for this are:

```
/topic/:id/latest_post

/votes/:id
api/v3/posts/:id/votes
/me/votes/:id
/posts/1,2,3/my_vote


/posts/:id/my_vote


```
