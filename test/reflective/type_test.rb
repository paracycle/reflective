require "test_helper"

module Foo
  class Bar
    def foo
    end

    def self.baz
    end

    PI = 3.14
    Baz = Class.new
    private_constant :Baz

    private

    def bar
    end
  end
end

module Reflective
  class TypeTest < Minitest::Test

    def test_can_find_type_by_name
      actual = Reflective::Type.for("Foo::Bar")
      expected = Reflective::Type.new(Foo::Bar)

      assert_equal(expected, actual)
    end

    def test_can_find_constants
      type = Reflective::Type.for("Foo::Bar")
      constants = type.constants

      assert_equal({ PI: 3.14 }, constants)
    end

    def test_can_find_own_instance_methods
      type = Reflective::Type.for("Foo::Bar")
      methods = type.methods

      assert_equal([:bar, :foo], methods.sort.map(&:name))
      assert_equal([:private, :public], methods.sort.map(&:visibility))
    end

    def test_can_find_public_own_instance_methods
      type = Reflective::Type.for("Foo::Bar")
      methods = type.methods(visibility: :public)

      assert_equal([:foo], methods.map(&:name))
      assert_predicate(methods.first, :public?)
      refute_predicate(methods.first, :static?)
    end

    def test_can_find_private_own_instance_methods
      type = Reflective::Type.for("Foo::Bar")
      methods = type.methods(visibility: :private)

      assert_equal([:bar], methods.map(&:name))
      assert_predicate(methods.first, :private?)
      refute_predicate(methods.first, :static?)
    end

    def test_can_find_own_class_methods
      type = Reflective::Type.for("Foo::Bar")
      methods = type.methods(kind: :class)

      assert_equal([:baz], methods.map(&:name))
      assert_predicate(methods.first, :public?)
      assert_predicate(methods.first, :static?)
    end
  end
end
