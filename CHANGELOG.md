# activerecord-postgres_pub_sub

## v3.1.0
- Add support for ActiveRecord 7.2
- Add support for Ruby 3.3

## v3.0.0
- Add support for multiple databases by allowing injection of the base Active Record class.
- BREAKING: Drop support for ActiveRecord 5.2, 6.0
- BREAKING: Drop support for ruby < 3.0

## v2.3.0
- Add support for Rails 7.1

## v2.2.0
- Add support for listening to multiple channels.

## v2.1.0
- Set required ruby version to 2.7.0
- Add support for Rails 7.0

## v2.0.1
- Fix version constraint on pg gem.
- Drop support for rails 5.1 as a result of pg constraint change.

## v2.0.0
- Add support for Rails 6.1.
- Drop support for pg 0.18 as support has been [dropped in activerecord 6.1](https://github.com/rails/rails/commit/592358e182effecebe8c6a4645bd4431f5a73654).

## v1.2.0
- Extend pg support to all of the `1.x` major version.

## v1.1.0
- Add support for Rails 6.0.

## v1.0.0
- No change.

## v0.5.0
- Add support for pg 1.1.3

## v0.4.0
- Add safe instance variable if StrongMigrations is used.

## v0.3.0
- Add support for Rails 5.2.

## v0.2.0
- Public release

## v0.1.0
- Initial version
