# frozen_string_literal: true

require_relative '../test_helper'

# NOTE A lot of these tests are interesting because they rely on ruby's
# parser to build trees with the correct precedence and associativity. This
# works nicely because our parser uses the same rules as ruby's.

class ParserTest < Minitest::Test
  include Mathcraft

  # This is a reduced version of `craft` for use in this test only. We don't
  # want to use `craft` because it uses Parser (in other words, don't write
  # tests for Parser that depend on Parser).
  def wrap(object)
    case object
    when Object then object
    when Numeric then Number.new(object)
    when Symbol then Variable.new(object)
    end
  end

  def assert_parsed(expected, input)
    expected = wrap(expected)

    assert_equal expected, Parser.new(input).parse,
      "Expected #{input.inspect} to parse to #{expected.inspect}"
  end

  def assert_parse_error(msg, input)
    Parser.new(input).parse
  rescue Parser::Error => e
    assert_equal msg, e.message
  end

  test 'parse numbers' do
    assert_parsed 64, '64'
    assert_parsed 3.14, '3.14'
    assert_parsed(-3, '-3') # We want a negative number, not a unary minus
  end

  test 'parse variables' do
    assert_parsed :x, 'x'
    assert_parsed :y, 'y'
  end

  test 'parse simple expression' do
    x = wrap(:x)

    assert_parsed x + 3, 'x + 3'
    assert_parsed wrap(4) - 3, '4 - 3'
    assert_parsed wrap(4) * x, '4 * x'
    assert_parsed x / x, 'x / x'
    assert_parsed x**2, 'x^2'
  end

  test 'parse with simple precedence' do
    x = wrap(:x)

    assert_parsed 3 + x * 3, '3 + x * 3'
    assert_parsed 3 + x * 3 + 4, '3 + x * 3 + 4'
    assert_parsed x / x - 4, 'x / x - 4'
    assert_parsed 10 * x**2 * 4, '10 * x^2 * 4'
  end

  test 'parse with simple associativity' do
    x = wrap(:x)

    assert_parsed 3 + x + 4 + x, '3 + x + 4 + x'
    assert_parsed 3 - x - 4 - x, '3 - x - 4 - x'
    assert_parsed 3 * x * 4 * x, '3 * x * 4 * x'
    assert_parsed 3 / x / 4 / x, '3 / x / 4 / x'
    assert_parsed 3**x**4**x, '3^x^4^x'
  end

  test 'parse with more complicated expression' do
    x = wrap(:x)

    assert_parsed x * 4 / 2**x**4 - 3 + -3 * x + wrap(4) * 2 - wrap(10) / 2,
      'x * 4 / 2^x^4 - 3 + -3x + 4 * 2 - 10 / 2'
  end

  test 'parse with parens' do
    x = wrap(:x)

    assert_parsed 2 * (x + 3), '2 * (x + 3)'
    assert_parsed 2 * (x + (3 - wrap(1))), '2 * (x + (3 - 1))'

    # Weird, but okay
    assert_parsed x + 3, '(x) + (3)'
    assert_parsed x + 3, '(x + 3)'
    assert_parsed x + 3, '(((((x)) + (3))))'
  end

  test 'unary minus' do
    x = wrap(:x)

    assert_parsed(-x, '-x')
    assert_parsed(--x, '--x')
    assert_parsed(-(x + 3), '-(x + 3)')
    assert_parsed(-wrap(-3), '--3') # unary minus of negative number
  end

  test 'unary minus precendence with exponent' do
    assert_parsed(-(wrap(3)**2), '-3^2')
    assert_parsed(-(wrap(:x)**2), '-x^2')
  end

  test 'implicit multiplication' do
    x, y, z = wrap(:x), wrap(:y), wrap(:z)

    assert_parsed 2 * x, '2x'
    assert_parsed x * y, 'xy'
    assert_parsed x * y * z, 'xyz'
    assert_parsed 2 * y * x, '2yx'
    assert_parsed wrap(2) * wrap(3), '2(3)'
    assert_parsed wrap(2) * wrap(3), '(2)3'
    assert_parsed wrap(2) * wrap(3), '(2)(3)'
    assert_parsed x * y**2, 'xy^2'
    assert_parsed x**2 * y, 'x^2 * y'
    assert_parsed x**2 * y, 'x^2y' # Implicit mult behaves like above
    assert_parsed x**(2 * y), 'x^(2y)'
  end

  test 'error with empty string' do
    assert_parse_error 'Expected value', ''
  end

  test 'error with missing operator' do
    assert_parse_error 'Expected operator', '3 4'
  end

  test 'error with missing right side' do
    assert_parse_error 'Expected value', '3 +'
    assert_parse_error 'Expected value', '3 + '
  end

  test 'error with missing closing paren' do
    assert_parse_error 'Expected closing paren', '(3 + 4'
  end

  test 'error with wildcard when not supported' do
    assert_parse_error 'Expected operator', 'x?'
  end
end
