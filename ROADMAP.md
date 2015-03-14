# Matterhorn Roadmap to v0.1.0

This document is here to track the current action items needed prior to initial
release of the library.

### Libs

- [ ] provides matcher
- [ ] inheritable-accessors delete/remove key
- [ ] inheritable-accessors simple setter/getter macro method.
- [ ] inheritable-accessors inheritable set accessor, upgrade matterhorn/resources params.
- [ ] response key lookup monad strategy

### Request testing

- [ ] move the collection tests back to the spec folder
- [x] controller error handling
- [x] index request spec
- [ ] show request spec
- [ ] show when using a comma separated list of ids
- [ ] create single
- [ ] create multiples
- [ ] update single
- [ ] update multiples (using a comma separated list of ids)
- [ ] delete spec
- [ ] delete multiples (using a comma separated list of ids)

### Includes

- [ ] spec new DSL for specifying the `in scope` to avoid a using the to proc
- [ ] Context object for models
- [ ] port belongs_to
- [ ] has_one (update has one vote, called through include=my_votes)
- [ ] belongs_to_many nested_comments_ids
- [ ] export to collection
- [ ] scoped_collection/scoped_resource should work on moped queries or mongoid collections

## DSL cleanup

- currently the lib requires you to both inherit from rails-api controller and include the resources components.
- manage the configuration for matterhorn logging, mongoid connections

### Filters

- [ ] paging link

### Testing macros

- [ ] provide
- [ ] provide\_inclusion
- [ ] provide\_link
- [ ] provide\_meta

### Search

- Decide how to handle search systems in the gem.

### URL Templates spec

### New docs