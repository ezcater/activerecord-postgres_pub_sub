# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "simplecov"
SimpleCov.start do
  add_filter("/spec/")
end

require "activerecord-postgres_pub_sub"
require "database_cleaner"
require "ezcater_matchers"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?
  config.order = :random
  Kernel.srand config.seed

  DATABASE_NAME = "postgres_pub_sub_test"

  config.before(:suite) do
    pg_version = `psql -t -c "select version()";`.strip
    puts "Testing with Postgres version: #{pg_version}"
    puts "Testing with ActiveRecord #{ActiveRecord::VERSION::STRING}"

    `dropdb --if-exists #{DATABASE_NAME} 2> /dev/null`
    `createdb #{DATABASE_NAME}`

    host = ENV.fetch("PGHOST", "localhost")
    port = ENV.fetch("PGPORT", 5432)
    database_url = "postgres://#{host}:#{port}/#{DATABASE_NAME}"
    puts "Using database #{database_url}"
    ActiveRecord::Base.establish_connection(database_url)
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:suite) do
    ActiveRecord::Base.connection_pool.disconnect!
    `dropdb --if-exists #{DATABASE_NAME}`
  end

  config.before do |example|
    DatabaseCleaner.strategy = example.metadata[:cleaner_strategy] || :transaction
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end
