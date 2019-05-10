require "test_helper"

class ReflectiveTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Reflective::VERSION
  end
end
