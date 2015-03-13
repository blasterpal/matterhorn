# Matterhorn

Matterhorn

**Under active development: this gem is currently under development at this time.**

* `rails-api` 4.x+ (rails 4.x)
* `mongoid`   4.x+ (will support 5.x when it comes out)
* `memcached`
* `rspec`     3.x

**Replica set friendly**. The system will provide 2 connection interfaces to mongo, a read operation and write operation  within the controllers.  By default these will assume you are writing to a majority, but reading from any node without confirmation.  You will need to modify the read/write parts of your controller if you want something more particular.

**Non-transactional writes by default**.  That means that when you PUT a resource and immediately refetch it, it will not be updated.

Overall planned items for a 0.1.0 release:

1. Support easy REST api creation and testing that follows the [json-api](http://jsonapi.org/) spec.  This would include but not be limited to:
   * inclusions
   * filters
   * selected fields
2. Mongoid 4.x compatibility

## Contributing

1. Fork it ( https://github.com/blakechambers/matterhorn/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
