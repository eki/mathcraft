# frozen_string_literal: true

require_relative '../test_helper'

class VariableTest < Minitest::Test
  include Mathcraft

  test 'new' do
    assert_equal 'v', Variable.new('v').value
    assert_equal 'y', Variable.new(:y).value
  end

  test 'to_s' do
    assert_equal 'v', Variable.new('v').to_s
    assert_equal 'z', Variable.new('z').to_s
  end

  test 'inspect' do
    assert_equal 'v', Variable.new('v').inspect
    assert_equal 'z', Variable.new('z').inspect
  end

  test '==' do
    assert_equal Variable.new('v'), Variable.new('v')
    assert_equal Variable.new('a'), Variable.new('a')

    refute_equal Variable.new('a'), Variable.new('b')
  end

  test 'eql?' do
    assert Variable.new('v').eql?(Variable.new('v'))
    assert Variable.new('a').eql?(Variable.new('a'))
    refute Variable.new('c').eql?(Variable.new('a'))
  end

  test 'hash' do
    assert_equal Variable.new('v').hash, Variable.new('v').hash
    assert_equal Variable.new('c').hash, Variable.new('c').hash
    refute_equal Variable.new('c').hash, Variable.new('a').hash
  end

  test '<=>' do
    assert_equal 0, Variable.new('x') <=> Variable.new('x')
    assert_equal(-1, Variable.new('x') <=> Variable.new('y'))
    assert_equal 1, Variable.new('x') <=> Variable.new('v')
  end

  test 'sort' do
    assert_equal [Variable.new('a'), Variable.new('v'), Variable.new('x')],
      [Variable.new('x'), Variable.new('a'), Variable.new('v')].sort
  end

  test 'type' do
    assert_equal 'variable', Variable.new('v').type
  end

  test 'number?' do
    refute Variable.new('v').number?
  end

  test 'variable?' do
    assert Variable.new('x').variable?
  end

  test 'expression?' do
    refute Variable.new('p').expression?
  end

  test 'lazy?' do
    assert Variable.new('x').lazy?
  end

  test 'to_lazy' do
    variable = Variable.new('x')

    assert_equal variable.object_id, variable.to_lazy.object_id
  end

  test 'immediate?' do
    refute Variable.new('x').immediate?
  end

  test 'to_immediate' do
    assert_equal Term.new(1, Variable.new('x') => 1),
      Variable.new('x').to_immediate
  end

  test 'substitute' do
    a = Variable.new('a')
    b = Variable.new('b')
    c = Variable.new('c')

    assert_equal a, a.substitute(b, c)
    assert_equal b, a.substitute(a, b)
  end
end
