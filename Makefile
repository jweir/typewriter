default:
	find . -name "*.rb" | entr bundle exec rake

bench:
	find . -name "*.rb" | entr ruby test/bench.rb

update:
	bin/tapioca annotations
	bin/tapioca gem --all
	bundle exec tapioca dsl
	bin/tapioca todo

generate:
	ruby -r ./generators/elements.rb -e 'Generators::Elements.call'
	ruby -r ./generators/attributes.rb -e 'Generators::Attributes.call'
	cat rbi/typewriter.rbx rbi/elements.rbx rbi/attributes.rbx > rbi/typewriter.rbi
	rubocop -A lib/typewriter/spec_elements.rb lib/typewriter/spec_attributes.rb rbi/**

build:
	rm *.gem
	gem build
