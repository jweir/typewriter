# frozen_string_literal: true

require_relative 'lib/typewriter'
require_relative 'lib/typewriter/version'

Gem::Specification.new do |spec|
  spec.name = 'typewriter'
  spec.version = Typewriter::VERSION
  spec.authors = ['John Weir']
  spec.email = ['john.weir@pharos-ei.com']

  spec.summary = 'HTML Generator via Ruby classes, not templates.'
  spec.description = 'It probably is not much fun, despite the name.'
  spec.homepage = 'https://github.com/jweir/typewriter'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/jweir/typewriter'
  spec.metadata['changelog_uri'] = 'https://github.com/jweir/typewriter/CHANGES.md'

  spec.files = Dir['lib/**/**', 'rbi/**/**']
  spec.require_paths = %w[lib rbi]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  # spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
