# frozen_string_literal: true

require_relative '../test_helper'

class TermTest < Minitest::Test
  include Mathcraft

  test 'new' do
    assert_equal Rational(3), Term.new(3, {}).coefficient
    assert_equal Rational(2), Term.new(Number.new(2), {}).coefficient
    assert_equal Rational(1, 2), Term.new(craft('1 / 2'), {}).coefficient

    assert_equal({ craft('x') => 1 }, Term.new(1, craft('x') => 1).variables)
    assert_equal({}, Term.new(0, craft('x') => 1).variables)
  end

  test 'one' do
    assert_equal Rational(1), Term.one.coefficient
    assert_equal({}, Term.one.variables)
    assert_equal Term.one.object_id, Term.one.object_id
  end

  test 'zero' do
    assert_equal Rational(0), Term.zero.coefficient
    assert_equal({}, Term.zero.variables)
    assert_equal Term.zero.object_id, Term.zero.object_id
  end

  test 'to_s' do
    assert_equal '2', Term.new(2, {}).to_s
    assert_equal '3 / 4', Term.new(Rational(3, 4), {}).to_s
    assert_equal 'x', Term.new(1, craft('x') => 1).to_s
    assert_equal '0', Term.zero.to_s
    assert_equal '1', Term.one.to_s
    assert_equal '2x', Term.new(2, craft('x') => 1).to_s
    assert_equal '2xy', Term.new(2, craft('x') => 1, craft('y') => 1).to_s
    assert_equal 'xy', Term.new(1, craft('x') => 1, craft('y') => 1).to_s
    assert_equal 'x^2y', Term.new(1, craft('x') => 2, craft('y') => 1).to_s
    assert_equal 'xy^2', Term.new(1, craft('x') => 1, craft('y') => 2).to_s
    assert_equal 'x^2y^2', Term.new(1, craft('x') => 2, craft('y') => 2).to_s
    assert_equal '3x^2y^2', Term.new(3, craft('x') => 2, craft('y') => 2).to_s
  end

  test 'inspect' do
    assert_equal '(term 1/1 {})', Term.one.inspect
    assert_equal '(term 0/1 {})', Term.zero.inspect

    one, two = '(term 1/1 {})', '(term 2/1 {})'
    assert_equal "(term 3/4 {x=>#{two}, y=>#{one}})",
      Term.new(Rational(3, 4), craft('x') => 2, craft('y') => 1).inspect
  end

  test 'to_lazy' do
    assert_equal craft(2), Term.new(2, {}).to_lazy
    assert_equal craft(0), Term.new(0, {}).to_lazy
    assert_equal craft(1), Term.new(1, {}).to_lazy
    assert_equal craft(Rational(1, 2)),
      Term.new(Rational(1, 2), {}).to_lazy
    assert_equal craft('x'), Term.new(1, craft('x') => 1).to_lazy
    assert_equal craft('2x'), Term.new(2, craft('x') => 1).to_lazy
    assert_equal craft('2xy'),
      Term.new(2, craft('x') => 1, craft('y') => 1).to_lazy
    assert_equal craft('xy'),
      Term.new(1, craft('x') => 1, craft('y') => 1).to_lazy
    assert_equal craft('x^2y'),
      Term.new(1, craft('x') => 2, craft('y') => 1).to_lazy
    assert_equal craft('xy^2'),
      Term.new(1, craft('x') => 1, craft('y') => 2).to_lazy
    assert_equal craft('x^2y^2'),
      Term.new(1, craft('x') => 2, craft('y') => 2).to_lazy
    assert_equal craft('3x^2y^2'),
      Term.new(3, craft('x') => 2, craft('y') => 2).to_lazy
  end

  test 'to_immediate' do
    term = Term.new(2, craft('x') => 2)

    assert_equal term.object_id, term.to_immediate.object_id
  end

  test '==' do
    assert_equal Term.one, Term.one
    assert_equal Term.new(3, craft('x') => 1), Term.new(3, craft('x') => 1)

    refute_equal Term.zero, Term.one
    refute_equal Term.new(2, craft('x') => 1), Term.new(3, craft('x') => 1)
    refute_equal Term.new(3, craft('y') => 1), Term.new(3, craft('x') => 1)
    refute_equal Term.new(3, craft('x') => 1),
      Term.new(3, craft('x') => 1, craft('y') => 1)
  end

  test 'eql?' do
    assert Term.one.eql?(Term.one)
    assert Term.new(3, craft('x') => 1).eql?(Term.new(3, craft('x') => 1))

    refute Term.zero.eql?(Term.one)
    refute Term.new(2, craft('x') => 1).eql?(Term.new(3, craft('x') => 1))
    refute Term.new(3, craft('y') => 1).eql?(Term.new(3, craft('x') => 1))
    refute Term.new(3, craft('x') => 1).eql?(
      Term.new(3, craft('x') => 1, craft('y') => 1))
  end

  test 'hash' do
    assert_equal Term.one.hash, Term.one.hash
    assert_equal Term.new(3, craft('x') => 1).hash,
      Term.new(3, craft('x') => 1).hash
  end

  test '<=>' do
    # rubocop:disable Lint/UselessComparison
    assert_equal 0, Term.zero <=> Term.zero
    assert_equal 0,
      Term.new(3, craft('x') => 2) <=> Term.new(3, craft('x') => 2)

    assert_equal 1, Term.zero <=> Term.one
    assert_equal(-1, Term.one <=> Term.zero)

    assert_equal 1,
      Term.new(1, craft('x') => 2) <=> Term.new(2, craft('x') => 3)
    assert_equal 1,
      Term.new(2, craft('x') => 2) <=> Term.new(Rational(5, 2), craft('x') => 2)
    assert_equal 1,
      Term.new(2, craft('x') => 2, craft('y') => 1) <=>
      Term.new(1, craft('x') => 2, craft('y') => 2)
    assert_equal 1,
      Term.new(1, craft('x') => 2) <=>
      Term.new(1, craft('x') => 2, craft('y') => 2)

    assert_equal(-1,
      Term.new(1, craft('x') => 3) <=> Term.new(2, craft('x') => 2))
    assert_equal(-1,
      Term.new(Rational(2, 3), craft('x') => 2) <=>
      Term.new(Rational(1, 3), craft('x') => 2))
    assert_equal(-1,
      Term.new(1, craft('x') => 2, craft('y') => 2) <=>
      Term.new(2, craft('x') => 2, craft('y') => 1))
    assert_equal(-1,
      Term.new(1, craft('x') => 2, craft('y') => 1) <=>
      Term.new(1, craft('x') => 2))

    assert_equal(-1, Term.new(1, craft('x') => 1) <=>
      Term.new(1, craft('y') => 1))
    # rubocop:enable Lint/UselessComparison
  end

  test 'sort' do
    expected = [
      Term.new(-3, craft('x') => 2, craft('y') => 2),
      Term.new(3, craft('x') => 1, craft('y') => 1),
      Term.new(3, craft('x') => 1),
      Term.new(2, craft('x') => 1),
      Term.one,
      Term.zero
    ]

    actual = [
      Term.new(3, craft('x') => 1),
      Term.new(-3, craft('x') => 2, craft('y') => 2),
      Term.one,
      Term.new(2, craft('x') => 1),
      Term.zero,
      Term.new(3, craft('x') => 1, craft('y') => 1)
    ]

    assert_equal expected, actual.sort
  end

  test 'term?' do
    assert Term.one.term?
    assert Term.new(3, craft('x') => 1).term?
  end

  test 'positive?' do
    assert Term.new(3, {}).positive?
    refute Term.zero.positive?
    refute Term.new(-1, {}).positive?
  end

  test 'negative?' do
    assert Term.new(-3, {}).negative?
    refute Term.zero.negative?
    refute Term.new(1, {}).negative?
  end

  test 'zero?' do
    refute Term.new(1, {}).zero?
    assert Term.zero.zero?
    refute Term.new(-3, {}).zero?
  end

  test 'one?' do
    assert Term.new(1, {}).one?
    refute Term.zero.one?
    refute Term.new(-3, {}).one?
  end

  test 'degree' do
    assert_equal 0, Term.one.degree
    assert_equal 1, Term.new(1, craft('x') => 1).degree
    assert_equal 2, Term.new(1, craft('x') => 2).degree
    assert_equal 3, Term.new(1, craft('x') => 1, craft('y') => 3).degree
    assert_equal 2, Term.new(1, craft('x') => 2, craft('y') => 1).degree
  end

  test 'like?' do
    assert Term.one.like?(Term.zero)
    assert Term.new(1, craft('x') => 1).like?(Term.new(1, craft('x') => 1))
    assert Term.new(3, craft('x') => 1).like?(Term.new(7, craft('x') => 1))
    refute Term.new(3, craft('x') => 2).like?(Term.new(7, craft('x') => 1))
    refute Term.new(3, craft('x') => 1).like?(Term.new(7, craft('y') => 1))
    refute Term.new(3, craft('x') => 1, craft('y') => 1).
      like?(Term.new(7, craft('x') => 1))
    refute Term.new(3, craft('x') => 1, craft('y') => 1).
      like?(Term.new(7, craft('x') => 1, craft('y') => 2))
    assert Term.new(3, craft('x') => 5, craft('y') => 7).
      like?(Term.new(7, craft('x') => 5, craft('y') => 7))
  end

  test 'reciprocal' do
    assert_equal Term.new(Rational(1, 4), craft('x') => -2),
      Term.new(4, craft('x') => 2).reciprocal

    term = Term.new(Rational(5, 2), craft('x') => 1, craft('y') => 100)
    assert_equal Term.one, term * term.reciprocal
  end

  test 'type' do
    assert_equal 'term', Term.one.type
  end

  test 'number?' do
    refute Term.one.number?
  end

  test 'variable?' do
    refute Term.one.variable?
  end

  test 'expression?' do
    refute Term.one.expression?
  end

  test 'lazy?' do
    refute Term.one.lazy?
  end

  test 'immediate?' do
    assert Term.one.immediate?
  end

  test '-@' do
    assert_equal Term.new(-3, {}), -Term.new(3, {})
    assert_equal Term.new(4, {}), -Term.new(-4, {})
    assert_equal Term.new(-1, craft('x') => 2),
      -Term.new(1, craft('x') => 2)
    assert_equal Term.zero, -Term.zero
  end

  test '+@' do
    term = Term.new(3, craft('y') => 3)
    assert_equal term.object_id, (+term).object_id
  end

  test '+ zero' do
    term = Term.new(Rational(12, 5), craft('z') => 4)
    assert_equal term.object_id, (term + Term.zero).object_id
    assert_equal term.object_id, (Term.zero + term).object_id
  end

  test '+ like' do
    term = Term.new(3, craft('z') => 4)
    like_one = Term.new(4, craft('z') => 4)
    like_two = Term.new(-3, craft('z') => 4)

    assert_equal Term.new(7, craft('z') => 4), term + like_one
    assert_equal Term.new(7, craft('z') => 4), like_one + term

    assert_equal Term.zero, term + like_two
    assert_equal Term.zero, like_two + term
  end

  test '+ unlike' do
    term = Term.new(3, craft('z') => 4)
    unlike = Term.new(3, craft('x') => 4)

    assert_equal Sum.new(term, unlike), term + unlike
    assert_equal Sum.new(term, unlike), unlike + term
  end

  test '- zero' do
    term = Term.new(Rational(12, 5), craft('z') => 4)
    assert_equal term.object_id, (term - Term.zero).object_id
  end

  test '- like' do
    term = Term.new(3, craft('z') => 4)
    like_one = Term.new(-4, craft('z') => 4)
    like_two = Term.new(3, craft('z') => 4)

    assert_equal Term.new(7, craft('z') => 4), term - like_one
    assert_equal Term.new(-7, craft('z') => 4), like_one - term

    assert_equal Term.zero, term - like_two
    assert_equal Term.zero, like_two - term
  end

  test '- unlike' do
    term = Term.new(3, craft('z') => 4)
    unlike = Term.new(3, craft('x') => 4)

    assert_equal Sum.new(term, -unlike), term - unlike
    assert_equal Sum.new(-term, unlike), unlike - term
  end

  test '* zero' do
    term = Term.new(3, craft('z') => 4)

    assert_equal Term.zero, term * Term.zero
    assert_equal Term.zero, Term.zero * term

    assert_equal Term.zero, Term.one * Term.zero
    assert_equal Term.zero, Term.zero * Term.one
  end

  test '* one' do
    term = Term.new(3, craft('z') => 4)

    assert_equal term.object_id, (term * Term.one).object_id
    assert_equal term.object_id, (Term.one * term).object_id
  end

  test '/ by zero' do
    assert_equal undefined, Term.new(3, {}) / Term.zero
  end

  test '/ by undefined' do
    assert_equal undefined, Term.new(3, {}) / undefined
  end

  test '/ by one' do
    term = Term.new(3, craft('z') => 4)

    assert_equal term.object_id, (term / Term.one).object_id
  end

  test '/ by self' do
    term = Term.new(3, craft('z') => 4)

    assert_equal Term.one, term / term
  end

  test '0 / by anything' do
    term = Term.new(3, craft('z') => 4)

    assert_equal Term.zero, Term.zero / term
  end

  test '/ non-term is ratio' do
    term = Term.new(3, craft('z') => 4)
    sum = Sum.new(term, Term.one)
    ratio = term / sum

    assert_equal Ratio, ratio.class
    assert_equal term, ratio.numerator
    assert_equal sum, ratio.denominator
  end

  test '/' do
    a = Term.new(8, craft('x') => 2, craft('y') => 4)
    b = Term.new(2, craft('x') => 1, craft('y') => 4)

    assert_equal Term.new(4, craft('x') => 1), a / b
  end

  test '/ that creates negative exponents becomes ratio' do
    a = Term.new(8, craft('x') => 2, craft('y') => 4)
    b = Term.new(2, craft('x') => 3, craft('y') => 4)

    ratio = Ratio.new(Term.new(4, {}), Term.new(1, craft('x') => 1))

    assert_equal ratio, a / b
  end

  test '** by 0' do
    term = Term.new(3, craft('z') => 4)

    assert_equal Term.one, term**0
  end

  test '** by undefined' do
    term = Term.new(3, craft('z') => 4)

    assert_equal undefined, term**undefined
  end

  test '0 ** by negative' do
    term = Term.new(-3, {})

    assert_equal undefined, Term.zero**term
  end

  test '0 ** by non-negative' do
    term = Term.new(3, craft('z') => 4)

    assert_equal Term.zero, Term.zero**term
  end

  test '0 ** by anything' do
    term = Term.new(3, craft('z') => 4)

    assert_equal Term.one, Term.one**term
  end

  test '**' do
    a = Term.new(3, craft('z') => 4)
    b = Term.new(2, {})

    assert_equal Term.new(9, craft('z') => 8), a**b
  end

  test '** resulting in negative exponent creates ratio' do
    a = Term.new(3, craft('z') => 2)
    b = Term.new(-1, {})

    ratio = Ratio.new(Term.one, a)

    assert_equal ratio, a**b
  end

  test 'abs' do
    assert_equal Term.one, Term.one.abs
    assert_equal Term.zero, Term.zero.abs
    assert_equal Term.one, (-Term.one).abs
  end
end
