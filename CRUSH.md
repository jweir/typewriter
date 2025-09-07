# Typewriter Development Guide

## Commands
- **Test all**: `bundle exec rake test` or `rake`
- **Test single file**: `bundle exec ruby test/typewriter/template_test.rb`
- **Lint**: `bundle exec rubocop`
- **Lint fix**: `bundle exec rubocop -A`
- **Watch tests**: `make` (uses entr to watch .rb files)
- **Benchmark**: `ruby test/bench`
- **Build gem**: `make build`
- **Generate code**: `make generate` (generates spec files and RBI)
- **Update Sorbet**: `make update` (updates tapioca annotations)

## Code Style
- **Frozen string literal**: Always include `# frozen_string_literal: true`
- **Sorbet typing**: Use `# typed: strict` for main files, `# typed: true` for tests
- **Imports**: Use `require_relative` for local files, `require` for gems
- **Classes**: Inherit from `Typewriter::Template` for templates, use modules for mixins
- **Methods**: Use single-line method definitions where appropriate (`def call = h1 { text 'Z' }`)
- **Attributes**: Use `Typewriter::Attribute.new` with blocks or chaining
- **HTML escaping**: All text is automatically escaped via ERB::Escape
- **Testing**: Use Minitest with `extend Minitest::Spec::DSL` for spec-style tests
- **Constants**: Use short aliases (`A = Typewriter::Attribute`, `T = Typewriter::Template`)
- **Naming**: Use `klass` instead of `class` for CSS class attributes
- **Error handling**: Raise exceptions for invalid usage (e.g., passing raw hashes as attributes)

## Architecture
- Templates use a buffer-based approach - call `render` to output and clear buffer
- Void elements (br, hr, img) self-close with `/>`
- Script tags don't escape content for JavaScript
- Use `join` to combine multiple templates
- Sorbet provides compile-time type checking for HTML elements and attributes
