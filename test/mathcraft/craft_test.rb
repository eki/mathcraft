# frozen_string_literal: true

require_relative '../test_helper'

class CraftTest < Minitest::Test
  include Mathcraft

  test 'craft with nil raises' do
    assert_raises { craft(nil) }
  end

  test 'craft with integers' do
    assert_equal Number.new(1), craft(1)

    n = craft(3)

    assert_equal Number, n.class
    assert_equal n.object_id, craft(n).object_id
  end

  test 'craft with floats' do
    assert_equal Number.new(1.1), craft(1.1)

    n = craft(3.14)

    assert_equal Number, n.class
    assert_equal n.object_id, craft(n).object_id
  end

  test 'craft with rationals' do
    assert_equal Number.new(1), craft(Rational(1))

    n = craft(Rational(3))

    assert_equal Number, n.class
    assert_equal n.object_id, craft(n).object_id

    expr = craft(Rational(4, 3))

    assert_equal Number.new(4) / Number.new(3), expr
  end

  test 'craft with variables' do
    assert_equal Variable.new('x'), craft(:x)
    assert_equal Variable.new('x'), craft('x')

    x = craft(:x)

    assert_equal Variable, x.class
    assert_equal x.object_id, craft(x).object_id
  end

  test 'craft with string is parsed' do
    assert_equal 2 * Variable.new(:x) * Variable.new(:y), craft('2xy')
    assert_equal Variable.new(:x)**Number.new(2) / Number.new(4),
      craft('x^2 / 4')
    assert_equal Expression, craft('x^2 / 4').class
  end

  test 'craft with equation' do
    eq = Equation.new(craft('x'), craft('3'))

    assert_equal eq, craft('x = 3')
    assert_equal eq.object_id, craft(eq).object_id
    assert craft('x = 3').lazy?
  end

  test 'craft! with nil raises' do
    assert_raises { craft!(nil) }
  end

  test 'craft! with integers' do
    assert_equal Term.one, craft!(1)

    n = craft!(3)

    assert_equal Term, n.class
    assert_equal n.object_id, craft!(n).object_id
  end

  test 'craft! with floats' do
    assert_equal Term.new(1.1, {}), craft(1.1)

    n = craft!(3.14)

    assert_equal Term, n.class
    assert_equal n.object_id, craft!(n).object_id
  end

  test 'craft! with rationals' do
    assert_equal Term.one, craft(Rational(1))

    n = craft!(Rational(3))

    assert_equal Term, n.class
    assert_equal n.object_id, craft!(n).object_id

    expr = craft!(Rational(4, 3))

    assert_equal Term.new(Rational(4, 3), {}), expr
  end

  test 'craft! with variables' do
    assert_equal Term.new(1, craft('x') => 1), craft!(:x)
    assert_equal Term.new(1, craft('x') => 1), craft!('x')

    x = craft!(:x)

    assert_equal Term, x.class
    assert_equal x.object_id, craft!(x).object_id
  end

  test 'craft! with string is parsed' do
    assert_equal Sum.new('x^2', 'y'), craft!('x^2 + y')
    assert_equal Sum.new('3/y', -10), craft!('3/y - 10')
  end

  test 'craft! with equation' do
    eq = Equation.new(craft!('x'), craft!('3'))

    assert_equal eq, craft!('x = 3')
    assert_equal eq.object_id, craft!(eq).object_id
    assert craft!('x = 3').immediate?
  end
end
