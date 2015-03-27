# Matterhorn Roadmap to v0.1.0

This document is here to track the current action items needed prior to initial
release of the library.  

Project goals:

* create simple resource and resources model when using Mongoid 4.x, Rails-api
  4.2, and ActiveModelSerialziers 0.8.3, that match the [json api][jsonapi]
  spec.
* Easy way to configure and setup links for paging/ordering.

### Specification support

Matterhorn should out of the box generate an API that is fully compliant with
the json api [conventions][conventions]. Here's some notes about some specifics,
broken down by supported and not supported.

_Note: Everything not supported in the below lists falls under "MAY" in the
spec._

#### Supported in 0.1.0

* [**Compound Documents**][compound-documents]. The ability to request links by
  name and include them in a response is already available in Matterhorn, and
  will be supported in 0.1.0.
* [**Top level "links"**][top-level-links].  Both the "self" link (effectively
  the servers current url for the page) and top level relationships are supported.
* [**Responses**][relationship-responses].  Planned support.
* [**Inclusion of Related Resources**][fetching-includes].  Planned support except
  for nested relationships.  Link relationships provided at the top level of
  the resource will be available for inclusions.  This section from the spec is
  **NOT** supported in 0.1.0:
  > For example, a relationship path could be comments.author, where comments is
  > a relationship listed under a articles resource object, and author is a
  > relationship listed under a comments resource object.

* [**Errors**](http://jsonapi.org/format/#errors). Errors returned from server will
  be keyed with a top level "errors" object.  Each error should provide a
  "title" per spec for any Matterhorn errors.  Later versions of the api should
  also provide "details" and "code".

#### Not supported in 0.1.0

* [**Top-level Meta**][meta].  for more information see: https://github.com/blakechambers/matterhorn/issues/18.
* [**Resource Relationships**][relationships]. Matterhorn will not initially
  support "self" links for named relationships and any requests to
  create/update/destroy those relationships.  Initially, like many Rails apps,
  relationships will be built using the foreign keys stored on respective
  resources.  Link updating will be planned for a future version of the gem.  
  (The "self" links will still be supported for both collection and resource
  GET methods. Any requests to the link resources will return a valid
  [`403 Forbidden`][relationship-403.)
* [**Fetching Relationships**][fetching-relationships]. Same as above, since
  matterhorn does not provide the "self" attribute, the ability to fetch those
  relationships is not provided.
* [**Sparse Fieldset**][sparsefieldsets]. Not supported.
* [**Sorting**][sorting].  Instead, matterhorn will allow you to specify, at the
  controller level, an [order][issue-10].  
  Available orders will be included as top level "orders".
* [ext=bulk][bulk]. No planned support initially.  See the note about bulk
  editing below.

#### Additionally supported items

* **Top level links**. Top level links **MAY** provide a URITemplate version of
  it's related link.
* **Bulk editing via comma separated lists of ids**.  For example,
  `DELETE /articles/1,2,3` would delete articles with ids 1, 2, and 3.  The
  initial version will only allow for a fixed number of documents to be updated
  via this manor, so clients updating a large amount of resources would need to
  make several requests.  The Matterhorn config should provide a configuration
  variable that will let apis set this value.

## 0.2.0 - DSL cleanup

* currently the lib requires you to both inherit from rails-api controller and
  include the resources components.
* manage the configuration for matterhorn logging, mongoid connections
* Decide how to handle search systems, aggregation, non-mongoid collections.

[jsonapi]: http://jsonapi.org
[conventions]: http://jsonapi.org/format/#conventions
[meta]: http://jsonapi.org/format/#document-structure-meta
[relationships]: http://jsonapi.org/format/#document-structure-resource-relationships
[fetching-relationships]: http://jsonapi.org/format/#fetching-relationships
[sparsefieldsets]: http://jsonapi.org/format/#fetching-sparse-fieldsets
[sorting]: http://jsonapi.org/format/#fetching-sorting
[compound-documents]: http://jsonapi.org/format/#document-structure-compound-documents
[top-level-links]: http://jsonapi.org/format/#document-structure-top-level-links
[relationship-responses]: http://jsonapi.org/format/#fetching-relationships-responses
[fetching-includes]: http://jsonapi.org/format/#fetching-includes
[relationship-403]: http://jsonapi.org/format/#crud-updating-relationship-responses-403
[issue-10]: https://github.com/blakechambers/matterhorn/issues/10
[bulk]: http://jsonapi.org/extensions/bulk/#creating-multiple-resources
