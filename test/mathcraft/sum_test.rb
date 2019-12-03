# frozen_string_literal: true

require_relative '../test_helper'

class SumTest < Minitest::Test
  include Mathcraft

  test 'new' do
    assert_equal({ Term.zero.variables => Term.zero }, Sum.new.terms)
    assert_equal({ Term.one.variables => Term.one }, Sum.new(Term.one).terms)

    term_x = craft('x').to_immediate
    term_3x = craft('3x').to_immediate
    term_4x = craft('4x').to_immediate
    term_2y = craft('2y').to_immediate

    assert_equal({ term_x.variables => term_4x, term_2y.variables => term_2y },
      Sum.new(term_x, term_2y, term_3x).terms)
  end

  test 'to_s' do
    assert_equal '2', Sum.new(2).to_s
    assert_equal 'x + 2', Sum.new('x', 2).to_s
    assert_equal 'x + 2', Sum.new(2, 'x').to_s
    assert_equal 'x - 2', Sum.new(3, -5, 'x').to_s
    assert_equal 'x^2 - xy + 10', Sum.new('-xy', 10, 'x^2').to_s
    assert_equal '-x', Sum.new('-x').to_s
    assert_equal '-x + 3', Sum.new('-x', 3).to_s
    assert_equal '-x - 3', Sum.new('-x', -3).to_s

    # TODO How to have sums of ratios?
    # assert_equal 'x / y - 3', Sum.new('x/y', -3).to_s
  end

  test 'inspect' do
    assert_equal '(sum {{}=>(term 0/1 {})})', Sum.new.inspect
    assert_equal '(sum {{}=>(term 3/1 {})})', Sum.new(3).inspect
    assert_equal '(sum {{x=>(term 1/1 {})}=>(term 1/1 {x=>(term 1/1 {})}), ' \
      '{}=>(term 3/1 {})})', Sum.new('x', 3).inspect
  end

  test 'to_lazy' do
    assert_equal craft(2), Sum.new(2).to_lazy
    assert_equal craft('x + 2'), Sum.new('x', 2).to_lazy
    assert_equal craft('x + 2'), Sum.new(2, 'x').to_lazy
    assert_equal craft('x - 2'), Sum.new(3, -5, 'x').to_lazy
    assert_equal craft('x^2 - xy + 10'), Sum.new('-xy', 10, 'x^2').to_lazy
    assert_equal craft('-x'), Sum.new('-x').to_lazy
    assert_equal craft('-x + 3'), Sum.new('-x', 3).to_lazy
    assert_equal craft('-x - 3'), Sum.new('-x', -3).to_lazy
  end

  test '==' do
    assert_equal Sum.new, Sum.new
    assert_equal Sum.new(2), Sum.new(2)
    assert_equal Sum.new(2), Sum.new(1, 1)
    assert_equal Sum.new('x'), Sum.new('x')
    assert_equal Sum.new('x'), Sum.new('3x', '-2x')
    assert_equal Sum.new('x', 3), Sum.new('3x', 2, '-2x', 1)
    assert_equal Sum.new('x', 'y'), Sum.new('3x', '-2y', '-2x', '3y')

    refute_equal Sum.new, Sum.new(3)
    refute_equal Sum.new(3), Sum.new(4)
    refute_equal Sum.new(3), Sum.new('x')
    refute_equal Sum.new('x'), Sum.new('2x')
    refute_equal Sum.new('x', 3), Sum.new('x', 4)
    refute_equal Sum.new('x', 3), Sum.new('2x', 3)
  end

  test 'eql?' do
    assert Sum.new.eql?(Sum.new)
    assert Sum.new(2).eql?(Sum.new(2))
    assert Sum.new(2).eql?(Sum.new(1, 1))
    assert Sum.new('x').eql?(Sum.new('x'))
    assert Sum.new('x').eql?(Sum.new('3x', '-2x'))
    assert Sum.new('x', 3).eql?(Sum.new('3x', 2, '-2x', 1))
    assert Sum.new('x', 'y').eql?(Sum.new('3x', '-2y', '-2x', '3y'))

    refute Sum.new.eql?(Sum.new(3))
    refute Sum.new(3).eql?(Sum.new(4))
    refute Sum.new(3).eql?(Sum.new('x'))
    refute Sum.new('x').eql?(Sum.new('2x'))
    refute Sum.new('x', 3).eql?(Sum.new('x', 4))
    refute Sum.new('x', 3).eql?(Sum.new('2x', 3))
  end

  test 'hash' do
    assert_equal Sum.new.hash, Sum.new.hash
    assert_equal Sum.new(2).hash, Sum.new(2).hash
    assert_equal Sum.new('x', 'y').hash, Sum.new('3x', '-2y', '-2x', '3y').hash
  end

  test '<=>' do
    # rubocop:disable Lint/UselessComparison
    assert_equal 0, Sum.new <=> Sum.new
    assert_equal 0, Sum.new(3) <=> Sum.new(3)
    assert_equal 0, Sum.new('x') <=> Sum.new('x')
    assert_equal 0, Sum.new('x', 3) <=> Sum.new('x', 3)

    # Some of these seem may seem weird, but we're sorting in term order, which
    # will seem backwards sometimes. For example, the term 1 is less than the
    # term 0 because we order them as "1 + 0".

    assert_equal 1, Sum.new <=> Sum.new(1)
    assert_equal 1, Sum.new <=> Sum.new('x')

    assert_equal(-1, Sum.new(1) <=> Sum.new)
    assert_equal(-1, Sum.new('x') <=> Sum.new)

    assert_equal 1, Sum.new(2) <=> Sum.new(3)
    assert_equal 1, Sum.new('y') <=> Sum.new('x')
    assert_equal 1, Sum.new('x') <=> Sum.new('x^2')

    assert_equal(-1, Sum.new(3) <=> Sum.new(2))
    assert_equal(-1, Sum.new('x') <=> Sum.new('y'))
    assert_equal(-1, Sum.new('x^2') <=> Sum.new('x'))
    # rubocop:enable Lint/UselessComparison
  end

  test 'sort' do
    expected = [
      Sum.new('x^2'),
      Sum.new('x'),
      Sum.new('x', 'y'),
      Sum.new('x', 3),
      Sum.new('x', -2),
      Sum.new('y'),
      Sum.new(1),
      Sum.new
    ]

    actual = [
      Sum.new('x'),
      Sum.new(1),
      Sum.new('y'),
      Sum.new('x', 3),
      Sum.new('x', 'y'),
      Sum.new,
      Sum.new('x^2'),
      Sum.new('x', -2)
    ]

    assert expected == actual.sort, 'Expected to sort to ' \
      "#{expected.map(&:to_s)}, actual: #{actual.sort.map(&:to_s)}"
  end

  test 'term?' do
    refute Sum.new(Term.one).term?
  end

  test 'to_term' do
    term = Term.new(Rational(1, 2), craft('z') => 50)
    assert_equal term.object_id, Sum.new(term).to_term.object_id
  end

  test 'type' do
    assert_equal 'sum', Sum.new.type
  end

  test 'number?' do
    refute Sum.new.number?
  end

  test 'variable?' do
    refute Sum.new.variable?
  end

  test 'expression?' do
    refute Sum.new.expression?
  end

  test 'lazy?' do
    refute Sum.new.lazy?
  end

  test 'immediate?' do
    assert Sum.new.immediate?
  end

  test 'zero?' do
    assert Sum.new.zero?
    assert Sum.new(0).zero?
    assert Sum.new('x', '-x').zero?
    refute Sum.new(1).zero?
  end

  test 'one?' do
    assert Sum.new(1).one?
    assert Sum.new('x', '-x', 1).one?
    refute Sum.new(0).one?
  end

  test '-@' do
    assert_equal Sum.new, -Sum.new
    assert_equal Sum.new(0), -Sum.new(0)
    assert_equal Sum.new(-1), -Sum.new(1)
    assert_equal Sum.new('-x'), -Sum.new('x')
    assert_equal Sum.new('x', -3), -Sum.new('-x', 3)
  end

  test '+@' do
    sum = Sum.new('x', 3)
    assert_equal sum.object_id, (+sum).object_id
  end

  test '+ zero' do
    sum = Sum.new('x')

    assert_equal sum.object_id, (sum + Term.zero).object_id
    assert_equal sum.object_id, (Term.zero + sum).object_id

    assert_equal sum.object_id, (sum + Sum.new).object_id
    assert_equal sum.object_id, (Sum.new + sum).object_id
  end

  test '+ like' do
    assert_equal Sum.new(4), Sum.new(1) + Sum.new(3)
    assert_equal Sum.new('5x'), Sum.new('x', 'x') + Sum.new('x', '3x', '-x')
    assert_equal Sum.new('2x', '3y'), Sum.new('x', 'y') + Sum.new('x', '2y')

    assert_equal Sum.new(0), Sum.new('3xyz') + Sum.new('-3xyz')
  end

  test '+ unlike' do
    assert_equal Sum.new('x', 'y'), Sum.new('x') + Sum.new('y')
    assert_equal Sum.new('x', '3'), Sum.new('x') + Sum.new('3')
  end

  test '+ undefined' do
    assert_equal undefined, Sum.new + undefined
  end

  test '- zero' do
    sum = Sum.new('x')

    assert_equal sum.object_id, (sum - Term.zero).object_id
    assert_equal sum.object_id, (sum - Sum.new).object_id
  end

  test '- like' do
    assert_equal Sum.new(-2), Sum.new(1) - Sum.new(3)
    assert_equal Sum.new('-x'), Sum.new('x', 'x') - Sum.new('x', '3x', '-x')
    assert_equal Sum.new('-y'), Sum.new('x', 'y') - Sum.new('x', '2y')

    assert_equal Sum.new('6xyz'), Sum.new('3xyz') - Sum.new('-3xyz')
  end

  test '- unlike' do
    assert_equal Sum.new('x', '-y'), Sum.new('x') - Sum.new('y')
    assert_equal Sum.new('x', '-3'), Sum.new('x') - Sum.new('3')
  end

  test '- undefined' do
    assert_equal undefined, Sum.new - undefined
  end

  test '* zero' do
    sum = Sum.new('x')

    assert_equal Term.zero, sum * Term.zero
    assert_equal Term.zero, Term.zero * sum

    assert_equal Term.zero, sum * Sum.new
    assert_equal Term.zero, Sum.new * sum
  end

  test '* one' do
    sum = Sum.new('x')

    assert_equal sum.object_id, (sum * Term.one).object_id
    assert_equal sum.object_id, (Term.one * sum).object_id

    assert_equal sum.object_id, (sum * Sum.new(1)).object_id
    assert_equal sum.object_id, (Sum.new(1) * sum).object_id
  end

  test '/ by zero' do
    assert_equal undefined, Sum.new('x') / Term.zero
    assert_equal undefined, Sum.new('x') / Sum.new(0)
  end

  test '/ by undefined' do
    assert_equal undefined, Sum.new('x') / undefined
  end

  test '/ by one' do
    sum = Sum.new('x', 3)

    assert_equal sum.object_id, (sum / Term.one).object_id
    assert_equal sum.object_id, (sum / Sum.new(1)).object_id
  end

  test '/ by self' do
    sum = Sum.new('x', 'y', 4)

    assert_equal Term.one, sum / sum
  end

  test '0 / by anything' do
    sum = Sum.new('x', 'y', 4)

    assert_equal Term.zero, Term.zero / sum
    assert_equal Term.zero, Sum.new(0) / sum
  end

  test '/ non-term is ratio' do
    a = Sum.new('a', 'c')
    b = Sum.new('b', 'd')
    ratio = a / b

    assert_equal Ratio, ratio.class
    assert_equal a, ratio.numerator
    assert_equal b, ratio.denominator
  end

  test '/' do
    a = Sum.new('10x', '12y')
    b = Sum.new('2')

    assert_equal Sum.new('5x', '6y'), a / b

    a = Sum.new('8x', '12y')
    b = Term.new('8', {})

    assert_equal Sum.new('x', '(3/2)y'), a / b
  end

  test '** by 0' do
    assert_equal Term.one, Sum.new('x', 'y')**0
  end

  test '** by undefined' do
    assert_equal undefined, Sum.new('x', 'y')**undefined
  end

  test '0 ** by negative' do
    assert_equal undefined, Sum.new(0)**Sum.new(-1)
  end

  test '0 ** by non-negative' do
    assert_equal Term.zero, Sum.new(0)**Term.new(4, {})
    assert_equal Term.zero, Sum.new(0)**Sum.new(4)
  end

  test '1 ** by anything' do
    assert_equal Term.one, Sum.new(1)**Sum.new(100)
    assert_equal Term.one, Sum.new(1)**Term.new(100, {})
  end

  test '**' do
    a = Sum.new('x', -4)
    b = Term.new(3, {})

    assert_equal Sum.new('x^3', '-12x^2', '48x', '-64'), a**b
  end
end
