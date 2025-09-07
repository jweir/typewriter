# frozen_string_literal: true
# typed: strict

require_relative 'attribute'
require_relative 'writer'
require 'erb/escape'

module Typewriter
  # Typewriter Template will generate typed HTML. Each tag and attribute has a
  # match method that is typed via Sorbet (which is optional).
  #
  # The template is designed to allow subclassing or using `start` to generate
  # templates without subclassing.
  #
  # When subclassing understand that `new` generatings a "buffer". Each time a
  # tag(div, b, body, etc) is called it will be added to the buffer. Once
  # `render` is called the buffer is is returned and then cleared.
  #
  #     class Example < Typewriter::Template
  #       def initialize(name)
  #         super()
  #         @name = name
  #       end
  #
  #       def view
  #         doctype
  #         html do
  #           body do
  #             h1 { text @name }
  #           end
  #         end
  #       end
  #     end
  #
  #     puts Example.new('My Example').view.render
  #     <!DOCTYPE html><html><body><h1>My Example</h1></body></html>
  #
  # If you need to create custom tags, create a method that integrates with the
  # Writer#write method.
  class Template
    include Typewriter::Writer
    include Typewriter::SpecElements::HTMLAllElements

    # To avoid subclassing a template, `start` can be used to yeild and return a Template.
    #
    #     html = Typewriter::Template.start do |t|
    #       t.doctype
    #       t.html do
    #         t.body { t.h1 "Body" }
    #       end
    #     end
    #
    def self.start(&block)
      obj = new
      yield obj if block
      obj
    end

    JOIN_ERROR = <<~TXT
      You can not join templates which are created by the parent template.

      This will fail:

        Typewriter::Template.start { |t| t.join [t.text("hello")] }

      Instead only join new templates
        Typewriter::Template.start do |t|
          t.join [Typewriter::Template.start { |x| x.text('hello') }]
        end
    TXT

    # join an array of other templates into this template.
    def join(templates)
      templates.each do |t|
        raise JOIN_ERROR if t == self

        @__buffer << t.render
      end
      self
    end

    # text will generate the text node, this is the only way to insert strings into the template.
    #
    #     Template.start do |t|
    #       t.div { t.text  "Hello" }
    #     end
    #
    def text(value)
      @__buffer << ERB::Escape.html_escape(value)
      self
    end

    # generate a comment block
    def comment(comment_text = nil)
      write('<!--', '-->', nil, closing_char: '') { text comment_text.to_s }
    end

    # generate the doctype
    def doctype
      @__buffer << '<!DOCTYPE html>'
      self
    end

    # generate a script tag. The return the script code to the block.
    # The code is not escaped.
    def script(attributes = nil, &block) # rubocop:disable Lint/UnusedMethodArgument
      body = yield
      write('<script', '</script>', attributes) { send :unsafe_text, body }
    end

    # attr is short cut in the template to return a new Attribute
    #
    # Template.start { |t| t.div(t.attr.id('my-div'), t.text '...') }
    def attr(&blk)
      if blk
        Attribute.new(&blk)
      else
        Attribute.new
      end
    end
  end
end
