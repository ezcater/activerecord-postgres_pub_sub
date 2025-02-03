# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "activerecord/postgres_pub_sub/version"

Gem::Specification.new do |spec|
  spec.name          = "activerecord-postgres_pub_sub"
  spec.version       = ActiveRecord::PostgresPubSub::VERSION
  spec.authors       = ["ezCater, Inc"]
  spec.email         = ["engineering@ezcater.com"]
  spec.summary       = "Support for Postgres Notify/Listen"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/ezcater/activerecord-postgres_pub_sub"
  spec.license       = "MIT"

  # Set "allowed_push_post" to control where this gem can be published.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  excluded_files = %w(.gitignore
                      .rspec
                      .rubocop.yml
                      .ruby-gemset
                      .tool-versions
                      Rakefile)

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(/^(bin|test|spec|features|.github)\//)
  end - excluded_files
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.0.0"

  spec.add_runtime_dependency "activerecord", "> 6.0", "< 8.1"
  spec.add_runtime_dependency "pg", "~> 1.1"
  spec.add_runtime_dependency "private_attr"
  spec.add_runtime_dependency "with_advisory_lock"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "ezcater_matchers"
  spec.add_development_dependency "ezcater_rubocop", "~> 6.1.0"
  spec.add_development_dependency "overcommit"
  spec.add_development_dependency "rake", "~> 13.1"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "simplecov"
end
