# frozen_string_literal: true

require_relative '../test_helper'

class RatioTest < Minitest::Test
  include Mathcraft

  test 'new' do
    ratio = Ratio.new('x', 2)

    assert_equal craft!('x'), ratio.numerator
    assert_equal craft!(2), ratio.denominator
  end

  test 'to_s' do
    assert_equal 'x / 2', Ratio.new('x', 2).to_s
    assert_equal '1 / y', Ratio.new(1, 'y').to_s
    assert_equal 'y', Ratio.new('y', 1).to_s
    assert_equal '2x / (yz)', Ratio.new('2x', 'yz').to_s
    assert_equal '(2x^2 + 10) / (y - 1)', Ratio.new('2x^2 + 10', 'y - 1').to_s
  end

  test 'inspect' do
  end

  test 'to_lazy' do
    assert_equal craft('x / 2'), Ratio.new('x', 2).to_lazy
    assert_equal craft('1 / y'), Ratio.new(1, 'y').to_lazy
    assert_equal 'y', Ratio.new('y', 1).to_s
    assert_equal craft('2x / (yz)'), Ratio.new('2x', 'yz').to_lazy
    assert_equal craft('(2x^2 + 10) / (y - 1)'),
      Ratio.new('2x^2 + 10', 'y - 1').to_lazy
  end

  test '==' do
    assert_equal Ratio.new('x', 2), Ratio.new('x', 2)
    assert_equal Ratio.new(1, 2), Ratio.new(4, 8)

    refute_equal Ratio.new('x', 2), Ratio.new('x', 4)
  end

  test 'eql?' do
    assert Ratio.new('x', 2).eql?(Ratio.new('x', 2))
    assert Ratio.new(1, 2).eql?(Ratio.new(4, 8))

    refute Ratio.new('x', 2).eql?(Ratio.new('x', 4))
  end

  test 'hash' do
    assert_equal Ratio.new('x', 2).hash, Ratio.new('x', 2).hash
    assert_equal Ratio.new(1, 2).hash, Ratio.new(4, 8).hash
  end

  test '<=>' do
    # rubocop:disable Lint/UselessComparison
    assert_equal 0, Ratio.new('x', 2) <=> Ratio.new('x', 2)

    assert_equal 1, Ratio.new('y', 2) <=> Ratio.new('x', 2)
    assert_equal(-1, Ratio.new('x', 2) <=> Ratio.new('y', 2))
    # rubocop:enable Lint/UselessComparison
  end

  test 'sort' do
    expected = [
      Ratio.new('x', 2)
    ]

    actual = [
      Ratio.new('x', 2)
    ]

    assert_equal expected, actual.sort
  end

  test 'ratio?' do
    assert Ratio.new('x', 2).ratio?
  end

  test 'zero?' do
    assert Ratio.new(0, 'x').zero?
    refute Ratio.new(1, 'x').zero?
  end

  test 'like?' do
    assert Ratio.new(1, 'x').like?(Ratio.new(2, 'x'))
    assert Ratio.new(1, 'xy').like?(Ratio.new('z', 'xy'))
    assert Ratio.new(1, 'x + 2').like?(Ratio.new('z', 'x + 2'))

    refute Ratio.new(1, 'y').like?(Ratio.new(2, 'x'))
    refute Ratio.new(1, 'xy').like?(Ratio.new('z', 'x + y'))
    refute Ratio.new(1, 'x + 3').like?(Ratio.new('z', 'x + 2'))
  end

  test 'type' do
    assert_equal 'ratio', Ratio.new('x', 2).type
  end

  test 'number?' do
    refute Ratio.new('x', 2).number?
  end

  test 'variable?' do
    refute Ratio.new('x', 2).variable?
  end

  test 'expression?' do
    refute Ratio.new('x', 2).expression?
  end

  test 'lazy?' do
    refute Ratio.new('x', 2).lazy?
  end

  test 'immediate?' do
    assert Ratio.new('x', 2).immediate?
  end

  test '-@' do
    assert_equal Ratio.new('-x', 2), -Ratio.new('x', 2)
  end

  test '+@' do
    ratio = Ratio.new('x', 2)

    assert_equal ratio.object_id, (+ratio).object_id
  end

  test '+ zero' do
    ratio = Ratio.new('x', 2)
    assert_equal ratio.object_id, (ratio + Term.zero).object_id
    assert_equal ratio.object_id, (Term.zero + ratio).object_id
  end

  test '+ like' do
    assert_equal Ratio.new('x + 3', 2), Ratio.new('x', 2) + Ratio.new(3, 2)
    assert_equal Ratio.new('3x', 'y'),
      Ratio.new('x', 'y') + Ratio.new('2x', 'y')
  end

  test '+ unlike' do
    ratio = Ratio.new('x', 2)
    unlike = Ratio.new('x', 'y + 2')

    assert_equal Sum.new(ratio, unlike), ratio + unlike
    assert_equal Sum.new(ratio, unlike), unlike + ratio
  end

  test '- zero' do
    ratio = Ratio.new('x', 2)
    assert_equal ratio.object_id, (ratio - Term.zero).object_id
  end

  test '- like' do
    assert_equal craft!('(1/2)x'), Ratio.new('3x', 2) - Ratio.new('2x', 2)
    assert_equal Term.zero, Ratio.new('x', 'y') - Ratio.new('x', 'y')
  end

  test '- unlike' do
    ratio = Ratio.new('x', '3y')
    unlike = Ratio.new('x', 'z')

    assert_equal Sum.new(ratio, -unlike), ratio - unlike
    assert_equal Sum.new(-ratio, unlike), unlike - ratio
  end

  test '* zero' do
    ratio = Ratio.new('x', 'y')

    assert_equal Term.zero, ratio * Term.zero
    assert_equal Term.zero, Term.zero * ratio

    assert_equal Term.zero, Term.one * Term.zero
    assert_equal Term.zero, Term.zero * Term.one
  end

  test '* one' do
    ratio = Ratio.new('x + 1', 'y + 1')

    assert_equal ratio.object_id, (ratio * Term.one).object_id
    assert_equal ratio.object_id, (Term.one * ratio).object_id
  end

  test '* cancels numerator' do
    assert_equal craft!('2x'), Ratio.new('2x', 'y + 3') * Sum.new('y', 3)
  end

  test '/ by zero' do
    assert_equal undefined, Ratio.new('x', 2) / Term.zero
  end

  test '/ by undefined' do
    assert_equal undefined, Ratio.new('x', 2) / undefined
  end

  test '/ by one' do
    ratio = Ratio.new('x', 2)

    assert_equal ratio.object_id, (ratio / Term.one).object_id
  end

  test '/ by self' do
    ratio = Ratio.new('x', 2)

    assert_equal Term.one, ratio / ratio
  end

  test '/' do
    a = Ratio.new('x', 2)
    b = Ratio.new(2, 'x')

    assert_equal craft!('(1/4)x^2'), a / b

    a = Ratio.new('x + 2', 2)
    b = Ratio.new('y', 'x')

    assert_equal Ratio.new('x^2 + 2x', '2y'), a / b
  end

  test '** by 0' do
    ratio = Ratio.new('x', 2)

    assert_equal Term.one, ratio**0
  end

  test '** by undefined' do
    ratio = Ratio.new('x', 2)

    assert_equal undefined, ratio**undefined
  end

  test '0 ** by non-negative' do
    ratio = Ratio.new('x', 'y')

    assert_equal Term.zero, Term.zero**ratio
  end

  test '1 ** by anything' do
    ratio = Ratio.new('x', 'y')

    assert_equal Term.one, Term.one**ratio
  end

  test '**' do
    a = Ratio.new('x', 'y')
    b = Term.new(3, {})

    assert_equal Ratio.new('x^3', 'y^3'), a**b
  end
end
