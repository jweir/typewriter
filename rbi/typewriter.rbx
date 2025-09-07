# typed: true
# frozen_string_literal: true

module Typewriter
  class Template
    JOIN_ERROR = T.let(T.unsafe(nil), String)

    include Typewriter::Writer
    include Typewriter::SpecElements::HTMLAllElements

    sig { params(block: T.proc.params(arg0: T.attached_class).void).returns(T.attached_class) }
    def self.start(&block); end

    sig { params(templates: T::Array[Typewriter::Writer]).returns(T.self_type) }
    def join(templates); end

    sig do
      params(blk: T.nilable(T.proc.params(arg0: Typewriter::Attribute).void)).returns(Typewriter::Attribute)
    end
    def attr(&blk); end

    sig { params(value: String).returns(T.self_type) }
    def text(value); end

    sig { returns(T.self_type) }
    def doctype; end

    sig do
      params(attributes: T.nilable(Typewriter::Attribute),
             block: T.proc.returns(String)).returns(T.self_type)
    end
    def script(attributes, &block); end

    sig { params(comment_text: T.nilable(String)).returns(T.self_type) }
    def comment(comment_text = nil); end
  end

  module Writer
    sig { void }
    def initialize
      @__buffer = T.let(+'', String)
    end

    sig { params(value: String).returns(T.self_type) }
    def unsafe_text(value); end

    sig { returns(String) }
    def render; end

    private

    sig { returns(String) }
    def new_string; end

    sig do
      params(open: String, close: String, attr: T.nilable(Typewriter::Attribute), closing_char: String,
             block: T.nilable(T.proc.params(arg0: Typewriter::Writer).void)).returns(T.self_type)
    end
    def write(open, close, attr = nil, closing_char: CLOSE, &block); end

    sig { params(open: String, attr: T.nilable(Typewriter::Attribute)).void }
    def write_void(open, attr = nil); end
  end

  class Attribute
    extend T::Sig

    sig do
      params(buffer: T::Hash[String, T.untyped], block: T.nilable(T.proc.params(arg0: Typewriter::Attribute).void)).void
    end
    def initialize(buffer = {}, &block) # rubocop:disable Lint/UnusedMethodArgument
      @__buffer = buffer
    end

    sig { params(suffix: String, value: String).returns(Typewriter::Attribute) }
    def data(suffix, value); end

    sig { params(name: String, value: String).returns(Typewriter::Attribute) }
    def attribute(name, value); end

    sig { params(value: String).returns(Typewriter::Attribute) }
    def klass(value); end

    sig { params(attr: T.nilable(Typewriter::Attribute)).returns(String) }
    def self.to_html(attr); end

    sig { params(list: T::Hash[String, T::Boolean]).returns(Typewriter::Attribute) }
    def classes(list); end

    sig { params(list: T::Hash[String, T::Boolean]).returns(Typewriter::Attribute) }
    def klasses(list); end

    sig { params(other: Typewriter::Attribute).returns(Typewriter::Attribute) }
    def merge(other); end

    sig { returns(String) }
    def safe_attribute; end

    sig { params(name: String, value: T.untyped).returns(Typewriter::Attribute) }
    def write(name, value); end

    sig { params(name: String, print: T::Boolean).returns(Typewriter::Attribute) }
    def write_boolean(name, print); end

    include Typewriter::SpecAttributes
  end
end
