# typed: true
# frozen_string_literal: true

require './lib/typewriter'
require 'minitest/autorun'
require 'minitest/spec'

module Typewriter
  class AttributeTest < Minitest::Test
    extend Minitest::Spec::DSL

    A = Typewriter::Attribute

    specify 'supports chainable attributes' do
      a = A.new.id('one').klass('k')

      assert_equal ' id="one" class="k"', a.safe_attribute
    end

    specify 'the data attibutes requires the name portion' do
      assert_equal(' data-abc-def="ok"', Typewriter::Attribute.new { |a| a.data('abc-def', 'ok') }.safe_attribute)

      assert_raises do
        Typewriter::Attribute.new { |a| a.data('abc:def', 'ok') }.safe_attribute
      end
    end

    specify 'the klass attibutes produces the class' do
      assert_equal(' class="big red"', Typewriter::Attribute.new { |a| a.klass('big red') }.safe_attribute)
    end

    specify 'attributes are supported' do
      a = Typewriter::Attribute.new do |at|
        at.klass('ok')
        at.id('1')
      end

      b = Typewriter::Attribute.new { _1.name('foo') }

      c = a.merge(b)

      assert_equal 'class="ok" id="1"', a.safe_attribute.strip
      assert_equal 'name="foo"', b.safe_attribute.strip
      assert_equal 'class="ok" id="1" name="foo"', c.safe_attribute.strip
    end

    specify 'attribute allows custom attributes on the node' do
      # the last attribute of that name will define the value
      a = Typewriter::Attribute.new { _1.attribute('foo', 'zoo').attribute('foo', 'bar').attribute('x', 'y') }
      assert_equal 'foo="bar" x="y"', a.safe_attribute.strip
    end

    specify 'attributes do not allow attributes to defined more than once' do
      a = Typewriter::Attribute.new do |at|
        at.id('one')
        at.name('ok')
        at.id('"two"')
      end
      c = a.merge(Typewriter::Attribute.new { _1.id('three') })
      assert_equal ' id="&quot;two&quot;" name="ok"', a.safe_attribute
      assert_equal ' id="three" name="ok"', c.safe_attribute
    end

    specify 'support boolean attributes' do
      a = Typewriter::Attribute.new.disabled(true)
      b = a.merge(Typewriter::Attribute.new.disabled(false))
      assert_equal ' disabled', a.safe_attribute
      assert_equal '', b.safe_attribute
    end

    specify 'classes includes the classes with a true value' do
      assert_equal ' class="foo zoo"',
                   Typewriter::Attribute.new.classes({ 'foo' => true, 'bar' => false, 'zoo' => true }).safe_attribute
    end
  end
end
