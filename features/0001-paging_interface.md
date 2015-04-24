# Paging interface

To help customize paging strategies, controllers should support adding a paging
interface.  This would allow common paging systems to be added easily across
different types of systems, without the need to modify a base paging class or
get fancy with more concerns.

## Usage

```ruby
class Article
  include Mongoid::Document
  include Mongoid::Timestamps
end

class Pagination

  # provides a LinkSet or config that can be merged into the request later.  
  # Links should be defined as a type inheriting from SetMember directly, not
  # from the association base class.
  attr_reader :links

  # resource    - scope (generally a Mongoid::Criteria)
  # page_params - param.permit(pagination_params)
  def initialize(resource, request_env, page_params, options)
    @links = LinkSet.new
  end

  def self.interfaced(controller)
    controller.pagination_params :limit, :offset
  end

  # specify the different types of links, and the code for each
  # here lets assume that we are defining, next, prev, and first.
  #
  # NOTE: this method will need access to the self link to be able
  #       to build first most of the time (i.e. to remove the current paging
  #       params)
  def self.links_config
    # ...
  end
end

class ArticlesController < ApplicationController
  include Matterhorn::Ordering
  include Matterhorn::Paging

  # would pass to a method and define inside the interface any needed paging
  # params via the collection_params method.
  paginates_with Pagination
end
```

Given the above implementation, the api should add links as such:


```json
GET /articles.json

{
  "links": {
    "self"  : "http://example.org/articles?page=2",
    "next"  : "http://example.org/articles?page=3",
    "prev"  : "http://example.org/articles?page=1",
    "first" : "http://example.org/articles",
  },
  "data" : "..."
}
```

### Questions

* Would controllers ever need to support multiple paging interfaces?  How would requests decide prioritization of one paging interface over another?  *Answer: Multiple interface support is not permitted in this version.  An error should be raised when developers attempt to specify multiple interfaces.*
