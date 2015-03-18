# Matterhorn Roadmap to v0.1.0

This document is here to track the current action items needed prior to initial
release of the library.

### Libs

- [ ] provides matcher https://github.com/blakechambers/serial-spec/issues/1
- [ ] inheritable-accessors delete/remove key
- [ ] inheritable-accessors simple setter/getter macro method.

### Request testing

- [x] move the collection tests back to the spec folder
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
- [ ] add inherited\_resources controller support for urls, nesting

### Filters

- [ ] paging link

## 0.2.0 - DSL cleanup

- currently the lib requires you to both inherit from rails-api controller and include the resources components.
- manage the configuration for matterhorn logging, mongoid connections
- Decide how to handle search systems, aggregation, non-mongoid collections.