# frozen_string_literal: true

require_relative '../test_helper'

class ExpressionTest < Minitest::Test
  include Mathcraft

  test 'new' do
    expr = Expression.new('+', 1, 2)
    assert_equal '+', expr.operator
    assert_equal [1, 2], expr.args
    assert expr.args.all?(&:number?)
  end

  test '-@' do
    x = craft(:x)
    expr = -x
    assert_equal '*', expr.operator
    assert_equal [-1, x], expr.args
  end

  test '+@' do
    x = craft(:x)
    assert_equal x, +x
  end

  test '+' do
    x = craft(:x)
    expr = 4 + x
    assert_equal '+', expr.operator
    assert_equal [4, x], expr.args
  end

  test '-' do
    expr = craft(2) - 10
    assert_equal '-', expr.operator
    assert_equal [2, 10], expr.args
  end

  test '*' do
    x, y = craft(:x), craft(:y)
    expr = x * y
    assert_equal '*', expr.operator
    assert_equal [x, y], expr.args
  end

  test '/' do
    expr = craft(5) / 2
    assert_equal '/', expr.operator
    assert_equal [5, 2], expr.args
  end

  test '^' do
    x = craft(:x)
    expr = x ^ 2
    assert_equal '^', expr.operator
    assert_equal [x, 2], expr.args
  end

  test '**' do
    x = craft(:x)
    expr = x**2
    assert_equal '^', expr.operator
    assert_equal [x, 2], expr.args
  end

  test 'equal' do
    x, y = craft(:x), craft(:y)

    assert_equal x * 3, x * 3
    assert_equal x - y, x - y

    refute_equal x - y, x * y
    refute_equal x * 3, x * 4
  end

  test 'coerce' do
    x = craft(:x)

    assert_equal craft(3) * 4, 3 * craft(4)
    assert_equal craft(Rational(3)) * x, Rational(3) * x
  end

  test '<=> with expressions' do
    # rubocop:disable Lint/UselessComparison
    assert_equal 0, craft('3 + 4') <=> craft('3 + 4')
    assert_equal 0, craft('x * y') <=> craft('x * y')

    # We know these are mathematically the same, but they're sorted by first
    # argument
    assert_equal(-1, craft('3 + 4') <=> craft('4 + 3'))
    assert_equal(-1, craft('x * y') <=> craft('y * x'))
    assert_equal 1, craft('4 + 3') <=> craft('3 + 4')
    assert_equal 1, craft('z * y') <=> craft('y * z')
    # rubocop:enable Lint/UselessComparison
  end

  test 'is a tree' do
    x, y = craft(:x), craft(:y)

    expr = x * 3 + y / 4
    assert_equal '+', expr.operator
    assert_equal [x * 3, y / 4], expr.args
    assert expr.args.all?(&:expression?)
  end

  test 'map' do
    expr = craft('3 + x * (y - 4)')
    expected = craft('(3 + 1) + x * (y - (4 + 1))')

    assert_equal(expected, expr.map { |obj| obj.number? ? obj + 1 : obj })
  end

  test 'inspect' do
    x, y = craft(:x), craft(:y)

    assert_equal '(+ 3 x)', (3 + x).inspect
    assert_equal '(+ (* x y) 10)', (x * y + 10).inspect
  end

  test 'rational?' do
    x = craft('x')

    assert((craft(3) / 4).rational?)
    assert((craft(3) * 4).rational?)
    assert((craft(3) + 4).rational?)
    assert((craft(3) - 4).rational?)
    assert((craft(3)**4).rational?)

    refute((x / 4).rational?)
    refute((x * 4).rational?)
  end

  test 'to_r' do
    assert_equal Rational(3, 4), (craft(3) / 4).to_r
    assert_equal 12r, (craft(3) * 4).to_r
    assert_equal 7r, (craft(3) + 4).to_r
    assert_equal(-1r, (craft(3) - 4).to_r)
    assert_equal 81r, (craft(3)**4).to_r
  end

  test 'to_numeric' do
    assert_equal Rational(3, 4), (craft(3) / 4).to_numeric
    assert_equal 12, (craft(3) * 4).to_numeric
    assert_equal 7, (craft(3) + 4).to_numeric
    assert_equal(-1, (craft(3) - 4).to_numeric)
    assert_equal 81, (craft(3)**4).to_numeric
  end

  test 'to_numeric is recursive' do
    assert_equal Rational(3, 4), craft('(5 - 2) / (1+1)^2').to_numeric
    assert_equal 81, craft('(5 + 4) * (18 / 6)^2').to_numeric
  end

  test 'to_r is recursive' do
    assert_equal Rational(3, 4), craft('(5 - 2) / (1+1)^2').to_r
  end

  test 'to_immediate (terms)' do
    assert_equal Term.new(12, {}), craft('3 * 4').to_immediate
    assert_equal Term.new(3, craft('x') => 1), craft('3 * x').to_immediate
    assert_equal Term.new(12, craft('x') => 1), craft('3 * x * 4').to_immediate

    assert_equal Term.new(1, craft('x') => 1, craft('y') => 1),
      craft('x * y').to_immediate

    assert_equal Term.new(1, craft('x') => 2), craft('x^2').to_immediate

    assert_equal Term.new(1, craft('x') => 2, craft('y') => 1),
      craft('x^2 * y').to_immediate

    assert_equal Term.new(15, craft('x') => 2, craft('y') => 4),
      craft('5 * x^2 * y * y^3 * 3').to_immediate

    assert_equal Term.new(Rational(1, 2), craft('x') => 1),
      craft('(1/2)x').to_immediate
  end

  test 'to_immediate (sums)' do
    assert Sum.new(craft('3').to_immediate, craft('4').to_immediate),
      craft('3 + 4').to_immediate
    assert Sum.new(craft('x').to_immediate, craft('2').to_immediate),
      craft('x + 2').to_immediate
    assert Sum.new(craft('x').to_immediate, craft('2').to_immediate),
      craft('2 + x').to_immediate
    assert Sum.new(craft('x').to_immediate, craft('2').to_immediate,
      craft('3z').to_immediate), craft('3z + z + 2').to_immediate
  end
end
