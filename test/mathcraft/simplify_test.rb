# frozen_string_literal: true

require_relative '../test_helper'

class SimplifyTest < Minitest::Test
  include Mathcraft

  def assert_simplified(expected, other)
    expected, other = craft(expected), craft(other)

    assert_equal expected, other.to_immediate.to_lazy,
      "Expected #{other.inspect} to simplify to #{expected.inspect}"
  end

  test 'simply arithmetic with numbers' do
    assert_simplified 4, '2 + 2'
    assert_simplified 0, '2 - 2'
    assert_simplified 6, '2 * 3'
    assert_simplified 4, '16 / 4'
    assert_simplified 64, '2^6'
  end

  test 'simplify with more complex arithmetic with numbers' do
    assert_simplified 30, '(((10 / 2)^2 - 13) / 4) * 10'
    assert_simplified 106, '2 * 3 * 4 * 5 - 5 - 4 - 3 - 2'
    assert_simplified '1 / 8', '2^(-10 + 7)'
  end

  test 'simplify division reduces to whole number' do
    assert_simplified 10, '100 / 10'
  end

  test 'simplify division reduces to expression' do
    assert_simplified '7 / 2', '7 / 2'
  end

  test 'simplify fractions' do
    assert_simplified '7 / 2', '21 / 6'
  end

  test 'simplfy arithmetic with fractions' do
    assert_simplified '13 / 3', '3 + 4 / 3'
    assert_simplified '13 / 3', '4 / 3 + 3'
    assert_simplified '7 / 2', '4 - 1 / 2'
    assert_simplified '-19 / 2', '1 / 2 - 10'
    assert_simplified 1, '2(1 / 2)'
    assert_simplified 5, '(1 / 2)10'
    assert_simplified 2, '8 / 2 / 2'
    assert_simplified 4, '8 / (4 / 2)'
  end

  test 'anything divided by zero is undefined' do
    assert_simplified undefined, '4 / 0'
    assert_simplified undefined, '0 / 0'
    assert_simplified undefined, 'x / 0'
  end

  test 'undefined is contagious' do
    assert_simplified undefined, '(0/0) + 4'
    assert_simplified undefined, '(0/0) - 0'
    assert_simplified undefined, '(0/0) * 2'
    assert_simplified undefined, '(0/0) / 10'
    assert_simplified undefined, '(0/0)^9'

    assert_simplified undefined, '4 + (0/0)'
    assert_simplified undefined, '0 - (0/0)'
    assert_simplified undefined, '2 * (0/0)'
    assert_simplified undefined, '10 / (0/0)'
    assert_simplified undefined, '9^(0/0)'

    assert_simplified undefined, '(0/0) + (0/0)'
    assert_simplified undefined, '(0/0) - (0/0)'
    assert_simplified undefined, '(0/0) * (0/0)'
    assert_simplified undefined, '(0/0) / (0/0)'
    assert_simplified undefined, '(0/0)^(0/0)'

    assert_simplified undefined, '(3 + x) + (0/0)'
    assert_simplified undefined, '(3 + x) - (0/0)'
    assert_simplified undefined, '(3 + x) * (0/0)'
    assert_simplified undefined, '(3 + x) / (0/0)'
    assert_simplified undefined, '(3 + x)^(0/0)'

    assert_simplified undefined, '(3 / x) + (0/0)'
    assert_simplified undefined, '(3 / x) - (0/0)'
    assert_simplified undefined, '(3 / x) * (0/0)'
    assert_simplified undefined, '(3 / x) / (0/0)'
    assert_simplified undefined, '(3 / x)^(0/0)'
  end

  test 'anything to zero is zero' do
    assert_simplified 0, 'x * 0'
    assert_simplified 0, '0 * x'
  end

  test 'anything from itself is zero' do
    assert_simplified 0, 'x - x'
    assert_simplified 0, '2x - 2x'
    assert_simplified 0, 'x^y - x^y'
  end

  test 'anything divided by itself is one' do
    assert_simplified 1, 'x / x'
    assert_simplified 1, '(x + 3) / (x + 3)'
    assert_simplified 1, '(x / y) / (x / y)'
  end

  test 'anything divided by one is itself' do
    assert_simplified :x, 'x / 1'
    assert_simplified 'x + 3', '(x + 3) / 1'
    assert_simplified 'x / y', '(x / y) / 1'
  end

  test 'zero divided by anything is zero' do
    assert_simplified 0, '0 / x'
    assert_simplified 0, '0 / (x + 3)'
    assert_simplified 0, '0 / (x^y)'
  end

  test 'tricky zero divided by zero is undefined' do
    # This verifies that x - x is reduced to zero before
    # anything / anyting is reduced to 1
    assert_simplified undefined, '(x - x) / (x - x)'
  end

  test 'anything and zero is itself' do
    assert_simplified :x, 'x + 0'
    assert_simplified :x, '0 + x'
    assert_simplified 'x + 3', '(x + 3) + 0'
    assert_simplified 'x + 3', '0 + (x + 3)'
  end

  test 'taking zero from anything is itself' do
    assert_simplified :x, 'x - 0'
    assert_simplified 'x + 3', '(x + 3) - 0'
  end

  test 'anything from zero is the negative of itself' do
    assert_simplified '-x', '0 - x'
    assert_simplified '-x - 3', '0 - (x + 3)'
  end

  test 'a double negative is positive' do
    assert_simplified :x, '--x'
    assert_simplified 'x + 3', '--(x + 3)'
  end

  test 'a triple negative is negative, etc' do
    assert_simplified '-x', '---x'
    assert_simplified 'x', '----x'
    assert_simplified '-x', '-----x'
    assert_simplified 'x', '------x'
    assert_simplified '-x', '-------x'
  end

  test 'anything times one is itself' do
    assert_simplified :x, 'x * 1'
    assert_simplified :x, '1 * x'
    assert_simplified 'x + 3', '(x + 3) * 1'
    assert_simplified 'x + 3', '1 * (x + 3)'
  end

  test 'anything to the zero power is one' do
    assert_simplified 1, 'x^0'
    assert_simplified 1, '4^0'
    assert_simplified 1, '0^0'
    assert_simplified 1, '(x + 3)^0'
    assert_simplified 1, '(x + 3)^(x - x)'
  end

  test 'zero to any power is zero' do
    assert_simplified 0, '0^x'
    assert_simplified 0, '0^4'
    assert_simplified 0, '0^(x + 3)'
    assert_simplified 0, '(x - x)^(x + 3)'
  end

  test 'one to any power is one' do
    assert_simplified 1, '1^x'
    assert_simplified 1, '1^4'
    assert_simplified 1, '1^(x + 3)'
    assert_simplified 1, '(x / x)^(x + 3)'
  end

  test 'anything to the first power is itself' do
    assert_simplified :x, 'x^1'
    assert_simplified 4, '4^1'
    assert_simplified 0, '0^1'
    assert_simplified 'x + 3', '(x + 3)^1'
    assert_simplified 'x + 3', '(x + 3)^(x / x)'
  end

  test 'anything a negative power is one over itself to the positive power' do
    assert_simplified '1 / x', 'x^-1'
    assert_simplified '1 / 4', '4^-1'
    assert_simplified '1 / 16', '4^-2'
    assert_simplified undefined, '0^-1'
    assert_simplified undefined, '0^-999'
    assert_simplified '1 / (x + 3)', '(x + 3)^-1'
    assert_simplified '1 / (x^4 + 12x^3 + 54x^2 + 108x + 81)', '(x + 3)^-4'
  end

  test 'anything plus itself is twice itself' do
    assert_simplified '2x', 'x + x'

    # This is a slightly weird example because it simplifies down further
    assert_simplified '2x + 6', '(x + 3) + (x + 3)'

    assert_simplified '3x', '2x + x'
    assert_simplified '3x', 'x + 2x'

    assert_simplified '5x', '2x + x3'
    assert_simplified '5x', '3x + 2x'

    assert_simplified '2x^y', 'x^y + x^y'
  end

  test 'anything times itself is squared' do
    assert_simplified 'x^2', 'x * x'
    assert_simplified 'x^2 + 6x + 9', '(x + 3) * (x + 3)'
    assert_simplified 'x^(2y)', 'x^y * x^y'
  end

  test 'add like exponents' do
    assert_simplified 'x^3', 'x^2 * x'
    assert_simplified 'x^3', 'x * x^2'
    assert_simplified 'x^5', 'x^2 * x^3'
  end

  test 'simplify relies on sorting and grouping of like terms' do
    assert_simplified '5x + 4y', 'y + x + y + 3 * x + y + x + y'
    assert_simplified '2x^6 * y^2', '(2 * x^3) * y * x * y * x^2'
  end

  test 'raising term to non-rational exponent' do
    assert_simplified 'x^y', 'x^y'
    assert_simplified 'x^y4^y', '(4x)^y'
  end

end
