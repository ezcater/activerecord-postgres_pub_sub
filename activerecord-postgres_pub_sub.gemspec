lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "activerecord-postgres_pub_sub/version"

Gem::Specification.new do |spec|
  spec.name          = "activerecord-postgres_pub_sub"
  spec.version       = ActiveRecord::PostgresPubSub::VERSION
  spec.authors       = ["ezCater, Inc"]
  spec.email         = ["engineering@ezcater.com"]

  spec.summary       = "Support for Postgres Notify/Listen"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/ezcater/activerecord-postgres_pub_sub"
  

  # Set "allowed_push_post" to control where this gem can be published.
  # rubocop:disable Style/GuardClause
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://ezcater.jfrog.io"
  
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end
  # rubocop:enable Style/GuardClause

  excluded_files = %w(.circleci/config.yml
                      .github/PULL_REQUEST_TEMPLATE.md
                      .gitignore
                      .rspec
                      .rubocop.yml
                      .ruby-gemset
                      .ruby-version
                      .travis.yml
                      bin/console
                      bin/setup
                      Rakefile)

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end - excluded_files
  spec.bindir        = "bin"
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  
  spec.add_development_dependency "ezcater_gem", ">= 0.2.0"
  
  spec.add_development_dependency "ezcater_rubocop"
  spec.add_development_dependency "overcommit"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "rspec_junit_formatter", "0.2.2"
  spec.add_development_dependency "simplecov"
end
