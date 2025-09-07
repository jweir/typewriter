# typed: true
# frozen_string_literal: true

require './lib/typewriter'
require 'minitest/autorun'
require 'minitest/spec'

module Typewriter
  class TemplateTest < Minitest::Test
    extend Minitest::Spec::DSL

    Item = Struct.new(:name)
    A = Typewriter::Attribute
    T = Typewriter::Template

    class X < Typewriter::Template
      def call(item)
        h1(A.new do |a|
          a.id('big')
          a.klass('a "b" c')
        end) do
          text(item.name)
          br
          b { text('Hello & good "byte"') }
        end
      end
    end

    specify 'escaped comments supported' do
      assert_equal '<p><!--no comment--></p>', Typewriter::Template.start { |x| x.p { x.comment 'no comment' } }.render
      assert_equal '<p><!----></p>', Typewriter::Template.start { |x| x.p { x.comment } }.render, 'empty comment'
      assert_equal '<p><!--&lt;b&gt;html&lt;/b&gt;--></p>', Typewriter::Template.start { |x|
        x.p do
          x.comment '<b>html</b>'
        end
      }.render, 'escaped comment'
    end

    specify 'empty non-void nodes close correctly' do
      assert_equal '<div></div>', T.new.div.render
      assert_equal '<span></span>', T.new.span.render
      assert_equal '<form></form>', T.new.form.render
    end

    specify 'doctype supported' do
      template = Typewriter::Template.new
      template.doctype
      assert_equal '<!DOCTYPE html>', template.render
    end

    specify 'renders HTML and attributes' do
      assert_equal \
        '<h1 id="big" class="a &quot;b&quot; c">ITEM<br/><b>Hello &amp; good &quot;byte&quot;</b></h1>',
        X.new.call(Item.new('ITEM')).render
    end

    class Z < Typewriter::Template
      def call = h1 { text 'Z' }
    end

    specify 'calling render clears the buffer (ie it does not double render)' do
      t = Z.new
      t.call.render
      result = t.call.render
      assert_equal '<h1>Z</h1>', result
    end

    specify 'handles whitespace correctly' do
      template = Typewriter::Template.start do |t|
        t.html do
          t.text(
            <<~TXT
              Hello,

              My name is Joe.
              Bye.
            TXT
          )
        end
      end

      assert_equal "<html>Hello,\n\nMy name is Joe.\nBye.\n</html>", template.render
    end

    specify 'join combines an array of templates into a parent template' do
      a = T.start { |t| t.div { t.text 'A' } }
      b = T.start { |t| t.div { t.text 'B' } }
      c = T.start { |t| t.div { t.text 'C' } }
      m = T.start { |t| t.div { t.join([a, b, c]) } }

      assert_equal '<div><div>A</div><div>B</div><div>C</div></div>', m.render
    end

    specify 'join errors if a joined template is itself' do
      assert_raises do
        T.start { |t| t.join [t.text('A')] }
      end

      Typewriter::Template.start do |t|
        t.join [Typewriter::Template.start { |x| x.text('hello') }]
      end
    end

    specify 'text is html escaped' do
      t = Typewriter::Template.new
      assert_equal '&lt;script&gt;x&lt;/script&gt;', t.text('<script>x</script>').render
    end

    specify 'script tag does not escape contents' do
      @template = Typewriter::Template.new
      @template.script(nil) { "console.log('Hello, World!');" }
      assert_equal "<script>console.log('Hello, World!');</script>", @template.render
    end
  end

  # set of OpenAI generated tests
  class TypewriterTemplateTest < Minitest::Test
    A = Typewriter::Attribute
    def setup
      @template = Typewriter::Template.new
    end

    def test_text_sanitization
      unsafe_string = "<script>alert('XSS');</script>"
      @template.text(unsafe_string)
      assert_equal '&lt;script&gt;alert(&#39;XSS&#39;);&lt;/script&gt;', @template.render
    end

    def test_void_elements
      r = Typewriter::Template.start do |t|
        t.html do
          t.br
          t.hr
          t.img(A.new { |a| a.href '/image' })
        end
      end

      assert_equal '<html><br/><hr/><img href="/image"/></html>', r.render
    end

    def test_html_node_creation
      @template.html do |t|
        t.head do
          t.title { t.text 'My Page Title' }
        end
        t.body do
          t.h1 { t.text 'Heading' }
          t.p { t.text 'This is a paragraph.' }
        end
      end
      expected_output = '<html><head><title>My Page Title</title></head><body><h1>Heading</h1><p>This is a paragraph.</p></body></html>'
      assert_equal expected_output, @template.render
    end

    def test_attribute_sanitization
      @template.a(A.new { |a| a.href "javascript:alert('XSS')" }) { _1.text 'Click me' }
      assert_match(/href="javascript:alert\(&#39;XSS&#39;\)"/, @template.render)
    end

    def test_attribute_quoting
      @template.p(A.new { |a| a.klass 'class"with"quotes' }) { _1.text 'Test' }
      assert_match(/class="class&quot;with&quot;quotes"/, @template.render)
    end

    def test_self_closing_tags
      @template.img(A.new do |a|
        a.src('image.png')
        a.alt('An image')
      end)
      assert_match(%r{<img src="image.png" alt="An image"/>}, @template.render)
    end

    def test_invalid_html_escaping
      @template.text('<html><body>Invalid HTML</body></html>')
      assert_equal '&lt;html&gt;&lt;body&gt;Invalid HTML&lt;/body&gt;&lt;/html&gt;', @template.render
    end

    def test_only_allows_attributes
      assert_raises do
        @template.p(klass: 'my-class') { _1.text 'Test' }
        @template.render
      end
    end

    def test_attribute_method_aliasing
      @template.p(A.new { |a| a.klass 'my-class' }) { _1.text 'Test' }
      assert_match(/class="my-class"/, @template.render)
    end

    def test_html_structure
      @template.html do |t|
        t.body do
          t.div(A.new { |a| a.id 'main' }) do
            t.p { t.text 'Nested content' }
          end
        end
      end
      expected_structure = '<html><body><div id="main"><p>Nested content</p></div></body></html>'
      assert_equal expected_structure, @template.render
    end
  end
end
