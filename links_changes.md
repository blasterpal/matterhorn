## Merging Links & Inclusions

current downsides of links and inclusions:

- there isn't a good reason to define links using both `add_link` and `add_inclusion` in models.  They serve duplicate purposes.
- Currently, using `add_link` doesn't provide enough feedback when it's misconfigured.
- type is added to `LinkConfig`, as the set_member name.
- `as` option is redundant, should infer from association.
- `metadata`, `scope_class`, and `resource_field_key` is specific to associations, should be moved to parent associations subclass.
- Set member classes must define an `includable?` method to allow them to be added as inclusions during request.

## Goals

Overall, merge the best of syntax from Inclusions and Links together into set of configurations.  Inclusions should be available via an `includable?` method on the set member.

SetMember should have an Association class that inherits from it.  Associations logic should be moved there to make adding links for things like paging/filters more accessible.

**If possible, get rid of the thread variable.**

- [ ] association class changes
- [ ] link_config rewrite
- [ ] visit set_member
- [ ] Remove The InclusionSupport class dependency in the models and controllers, just leaving link support.

-----

### Example usage

```ruby
class Post
  include Mongoid::Document
  include Matterhorn::Links::LinkSupport

  has_many :votes

  scope = proc do |set_member, env|
    env[:current_user].votes.all
  end

  add_link :my_vote #,
    # relation_name: :votes,
    # scope:         scope,
    # nested:        true,
    # singleton:     true

  def self.matterhorn_url_options(obj)
    [obj]
  end
end
```

## URL construction, and a short rant

Url generation inside of this spec can be extremely flexible, so much so that creating something that will be moderately accessible at the start will be fairly difficult to get rolling.  Just riffing, here are some types of url permutationsurls for this are:

```ruby
"/topic/:id/latest_post"
"/votes/:id"
"api/v3/posts/:id/votes"
"/votes/{post.post_id}"
"/posts/1/my_vote"
"/posts/1,2,3/my_vote"
"/posts/{posts.id}/my_vote"
```

Keep in mind that while URI Templates are not required in the json-api spec, providing them, if possible, would be nice to have.

the best way to support this is to split the construction of nested and non-nested associations out.  Let's assume you have:

```ruby
class Post
  include Mongoid::Document

  has_many :comments
  add_link :comments
end

class Comment
  include Mongoid::Document

  belongs_to :post
  add_link   :post
end
```

In this example you could prefer a url syntax that is nested, which would provide these links:

```ruby
"/posts/1/comments"
"/posts/1,2,3/comments"
"/comments/1/post"
"/comments/1,2,3/post"
```

Or non-nested:

```ruby
"/posts/1"
"/posts/1,2,3"
"/comments/1"
"/comments/1,2,3"
```

The later does seem simpler, but the issue is: _you will need to accept additional fields on the model for these association keys._  Also, validations for things like "all comments must have a post" require additional validation coupling to be developed clientside (specifically tracking that a missing post_id will become an error on the post association not the field itself).

Setup a singleton, without nesting, can become complicated.  A singleton link would require use of filtering for example the link to a comments post would be `/comments?post_id=1,2,3`.  This creates a lot of complexity when building the and links.

Lastly, the the issue becomes that nested routes and non-nested routes are treated differently when you are trying to add things like namespacing.  Nested routes tend to want to keep namespaces of the parent, while non-nested will want to use a consistent namespace for it's resource class (i.e. all comments henceforth routed through ""/chat/comments/:id").

# matterhorn_url_options

For a

By default, when including LinkSupport to models, it will get:

```ruby
def self.matterhorn_url_options(obj)
  [obj]
end
```

This method will be used to create any urls for this object.  That would mean object would be passed an instance of a post, a post collection, a handful of posts, or enough information to build a uri template key.

This method would not be used to customize the urls of nested associations (for the end level items).

*note: this doesn't cover use cases for nested associations more than 1 level deep.*
