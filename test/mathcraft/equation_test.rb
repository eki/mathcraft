# frozen_string_literal: true

require_relative '../test_helper'

class EquationTest < Minitest::Test
  include Mathcraft

  test 'new' do
    eq = Equation.new(craft('x'), craft(3))
    assert_equal craft('x'), eq.left
    assert_equal craft(3), eq.right
  end

  test 'lazy?' do
    assert craft('x = 3').lazy?
    assert craft('x = 3').left.lazy?
    assert craft('x = 3').right.lazy?
    refute craft!('x = 3').lazy?
  end

  test 'immediate?' do
    assert craft!('x = 3').immediate?
    assert craft!('x = 3').left.immediate?
    assert craft!('x = 3').right.immediate?
    refute craft('x = 3').immediate?
  end

  test 'to_lazy' do
    eq = craft('x + 3 = y')
    assert eq.object_id, eq.to_lazy.object_id

    assert_equal eq, craft!('x + 5 - 2 = y').to_lazy
  end

  test 'to_immediate' do
    eq = craft!('x + 3 = y')
    assert eq.object_id, eq.to_immediate.object_id

    assert_equal eq, craft('x + 5 - 2 = y').to_immediate
  end

  test 'coerce' do
    eq = craft('x + 3 = y')
    assert_equal craft('x + 3 + 2 = y + 2'), 2 + eq

    eq = craft!('x + 3 = y')
    assert_equal craft!('x = y - 3'), -3 + eq
  end

  test 'inspect' do
    assert_equal '(= x 3)', craft('x = 3').inspect
    assert_equal '(= x (+ y 2))', craft('x = y + 2').inspect

    assert_equal '(= (term 1/1 {x=>(term 1/1 {})}) (term 3/1 {}))',
      craft!('x = 3').inspect
  end

  test 'to_s' do
    assert_equal 'x = 3', craft('x = 3').to_s
    assert_equal 'x = 3', craft!('x - 0 = 10 - 7').to_s
  end

  test '<=>' do
    assert_equal 0, craft('x = 3') <=> craft('x = 3')
    assert_equal 1, craft('x = 4') <=> craft('x = 3')
    assert_equal(-1, craft('x = 3') <=> craft('x = 4'))
    assert_equal 1, craft('y = 3') <=> craft('x = 3')
    assert_equal(-1, craft('x = 3') <=> craft('y = 3'))
  end

  test 'eql?' do
    assert craft('x = 3').eql?(craft('x = 3'))
    refute craft('x = 3').eql?(craft('x = 4'))
  end

  test 'hash' do
    assert_equal craft('x = 3').hash, craft('x = 3').hash
  end

  test '-@' do
    assert_equal craft('--x = --3'), -craft('-x = -3')
    assert_equal craft!('x = 3'), -craft!('-x = -3')
  end

  test '+@' do
    eq = craft('x = 3')

    assert_equal eq.object_id, (+eq).object_id
  end

  test '+' do
    assert_equal craft('x - 3 + 3 = 4 + 3'), craft('x - 3 = 4') + 3
    assert_equal craft('x = 7'), craft!('x - 3 = 4') + 3
  end

  test '-' do
    assert_equal craft('x + 3 - 3 = 4 - 3'), craft('x + 3 = 4') - 3
    assert_equal craft('x = 1'), craft!('x + 3 = 4') - 3
  end

  test '*' do
    assert_equal craft('x * x = 3 * x'), craft('x = 3') * craft('x')
    assert_equal craft('x^2 = 3x'), craft!('x = 3') * craft('x')
  end

  test '/' do
    assert_equal craft('x^2 / x = x / x'), craft('x^2 = x') / craft('x')
    assert_equal craft('x = 1'), craft!('x^2 = x') / craft('x')
  end

  test '^' do
    assert_equal craft('x^2 = 2^2'), craft('x = 2') ^ 2
    assert_equal craft('x^2 = 4'), craft!('x = 2') ^ 2
  end

  test '**' do
    assert_equal craft('x^2 = 2^2'), craft('x = 2')**2
    assert_equal craft('x^2 = 4'), craft!('x = 2')**2
  end

  test 'number?' do
    refute craft('x = 3').number?
  end

  test 'variable?' do
    refute craft('x = 3').variable?
  end

  test 'expression?' do
    refute craft('x = 3').expression?
  end

  test 'equation?' do
    assert craft('x = 3').equation?
  end
end
