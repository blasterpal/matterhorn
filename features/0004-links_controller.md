# Links controller

This is based around [#70][70].  

see [fetching relationships](http://jsonapi.org/format/#fetching-relationships).

> A server MUST support fetching relationship data for every relationship URL
> provided as a self link as part of a link object.

The docs provide a sample request for a link related.

```json
HTTP/1.1 200 OK
Content-Type: application/vnd.api+json

{
  "links": {
    "self": "/articles/1/links/author",
    "related": "/articles/1/author"
  },
  "data": {
    "type": "people",
    "id": "12"
  }
}
```

## Strategy

- [ ] Add Matterhorn::LinksController to ./app/controllers.
- [ ] Add a new top level serializer path (specifically [in the code][inthecode]) in the responder, for serializing instances of `set_member`.  Currently it delegates to ScopedCollectionSerializer and ScopedResourceSerializer.  When instances or kinds_of SetMember are passed it, it should elect to use a newly created `Matterhorn::Serialization::LinkSerializer`.  
- [ ] Each instance of set_member, should have the option to set it's serializer, via setting `active_model_serializer`.  It's possible that this would just need to be set on the base class of `SetMember`.
- each response should provide a top level "self" link, for the above example that would be "/articles/1/links/author".
- [ ] related should call the set_members url_for method with the parent object.  assuming the example above that would be: `set_member.url_for(article)`  where article is `Article.find("1")`.
- [ ] `data` should be set to the output of [`linkage` from the set_member instance][linkage] and should always be available.  Linkage is not always provided in the current serialization due to concerns for creating n+1 queries.  On has_many and has_one relations, linkage **should** still be provided by the new LinkSerializer (under the data top-level key), but **should not** be added back into the normal links serialization (i.e. when serializing the article).

To be able to get the "related" link, you'll need to rewrite the association chain to where it works correctly.

## Usage

## Questions


[70]: https://github.com/blakechambers/matterhorn/issues/70
[inthecode]: https://github.com/blakechambers/matterhorn/blob/master/lib/matterhorn/serialization/builder_support.rb#L36
[linkage]: https://github.com/blakechambers/matterhorn/blob/8d39e0040392a86bbe655d7980d67ce6c5f42770/lib/matterhorn/links/relation/base.rb#L92-L99
