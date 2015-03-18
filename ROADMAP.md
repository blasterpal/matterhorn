# Matterhorn Roadmap to v0.1.0

This document is here to track the current action items needed prior to initial
release of the library.

### Libs

- [ ] provides matcher
- [ ] inheritable-accessors delete/remove key
- [ ] inheritable-accessors simple setter/getter macro method.
- [x] inheritable-accessors inheritable set accessor, upgrade
      matterhorn/resources params.
- [x] response key lookup monad strategy (serial-spec 0.2.0)

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

- [x] Each inclusion creates a class.
- [x] `requested_inclusions` (one's asked for by client),
- [x] build a set of all available inclusions, will be needed to produce links.
- [x] spec new DSL for specifying the `in scope` to avoid a using the to proc
- [x] Context object for models
- [x] export to collection ("includes" should be an array)
- [ ] using a select, choose a subset of the available incluson classes
- [ ] port belongs_to
- [ ] has_one (update has one vote, called through include=my_votes)
- [ ] belongs_to_many nested_comments_ids
- [ ] scoped\_collection/scoped\_resource should work on moped queries or mongoid collections
- [ ] support nested routes.

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

- [ ] Decide how to handle search systems in the gem.

### URL Templates spec

### New docs