# activerecord-postgres_pub_sub

This gem contains support for PostgreSQL LISTEN and NOTIFY functionality:
[doc](https://www.postgresql.org/docs/9.6/static/libpq-notify.html).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "activerecord-postgres_pub_sub"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-postgres_pub_sub

## Usage

### Listener

The `Listener` class is used to handle notification messages on one or more
channels.

The listener can be configured with three blocks:

* **on_notify**: called whenever a notification is received.
* **on_start**: called before receiving any notifications.
* **on_timeout**: called based on a configurable timeout, when no notifications
  have been received.

When creating a listener, the following configuration is supported:

* **listen_timeout**: If set, the `on_timeout` block will be called if
  no notifications are received within this period. (Default `nil`).
* **notify_only**: A payload string can be included in notifications. By default
  the listener ignores the payload and coalesces multiple notifications into a
  single call. When this option is `false`, the `on_notify` block is called with
  the payload for each notification. (Default `true`).
* **base_class**: An Active Record class should you need to use a different base
  class (e.g. for multiple database support). (Default `ActiveRecord::Base`).
* **exclusive_lock**: Acquire a lock using
  [with_advisory_lock](https://github.com/ClosureTree/with_advisory_lock) prior to listening.
  This option ensures that a process as a singleton listener. (Default `true`).

Example:

```ruby
ActiveRecord::PostgresPubSub::Listener.listen("notify_channel", listen_timeout: 30) do |listener|
  listener.on_start do
    # when starting assume we missed something and perform regular activity
    handle_notification
  end

  listener.on_notify do
    handle_notification
  end

  listener.on_timeout do
    perform_regular_maintenance
  end
end
```

### Generator

This gem contains a Rails generator for a migration to add a trigger to notify on insert to a table.

The generator must be run with a model name corresponding to the table.

```bash
rails generate active_record:postgres_pub_sub:notify_on_insert --model_name NameSpace::Entity
```

In this example, notification events would be generated for the channel named `"name_space_entity"` based
on inserts to the `name_space_entities` table.

## Supported dependencies

This gem will not support versions of ruby and activerecord which no
longer receive security updates. It will support the latest major
version of the pg gem and it will be tested against the latest minor /
patch version of that gem.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/ezcater/activerecord-postgres_pub_sub.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
