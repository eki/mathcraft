# frozen_string_literal: true

require_relative '../test_helper'

class SolveTest < Minitest::Test
  include Mathcraft

  def assert_solved(expected, other)
    expected, other = craft(expected), craft(other)

    assert_equal expected, other.solve,
      "Expected #{other.inspect} to simplify to #{expected.inspect}"
  end

  test 'really easy' do
    assert_solved 'x = 3', 'x = 2 + 1'
    assert_solved 'x = -2', 'x = y - y - 2'
    assert_solved 'x = 10', 'x = 10x / x'
  end

  test 'move unlike terms to other side' do
    assert_solved 'x = 1', 'x - 2 = -1'
    assert_solved 'x = 10', '10 = x'
    assert_solved 'x = 13', '10 = x - 3'
    assert_solved 'x = -7', '10 = 3 - x'
  end

  test 'divide out terms' do
    assert_solved 'x = 2', '2x = 4'
    assert_solved 'x = 5', 'x = 3x - 10'
    assert_solved 'x = 1 / (yz)', 'xyz = 1'
  end

  test 'something more complicated' do
    assert_solved 'y = x', '(4y - 8) / (2x - 4) = 2'
  end

end
