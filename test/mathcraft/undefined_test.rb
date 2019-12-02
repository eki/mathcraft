# frozen_string_literal: true

require_relative '../test_helper'

class UndefinedTest < Minitest::Test
  include Mathcraft

  test 'new' do
    assert_raises do
      Undefined.new
    end
  end

  test 'to_s' do
    assert_equal 'undefined', undefined.to_s
  end

  test 'inspect' do
    assert_equal 'undefined', undefined.inspect
  end

  test 'is a singleton' do
    assert_equal undefined.object_id, undefined.object_id
    assert_equal undefined.object_id, Undefined::UNDEFINED.object_id
    assert_equal undefined.object_id, Mathcraft.undefined.object_id
  end

  test '==' do
    assert_equal undefined, undefined

    refute_equal Number.new(10), undefined
  end

  test 'eql?' do
    assert undefined.eql?(undefined)
  end

  test 'hash' do
    assert_equal undefined.hash, undefined.hash
  end

  test '<=>' do
    # rubocop:disable Lint/UselessComparison
    assert_equal 0, undefined <=> undefined
    # rubocop:enable Lint/UselessComparison
  end

  test 'type' do
    assert_equal 'undefined', undefined.type
  end

  test 'number?' do
    refute undefined.number?
  end

  test 'variable?' do
    refute undefined.variable?
  end

  test 'expression?' do
    refute undefined.expression?
  end

  test 'positive?' do
    refute undefined.positive?
  end

  test 'negative?' do
    refute undefined.negative?
  end

  test 'zero?' do
    refute undefined.zero?
  end

  test 'rational?' do
    refute undefined.rational?
  end

  test 'to_immediate' do
    assert_equal undefined, undefined.to_immediate
  end

  test 'to_lazy' do
    assert_equal undefined, undefined.to_lazy
  end

  test '-@' do
    assert_equal undefined, -undefined
  end

  test '+@' do
    assert_equal undefined, +undefined
  end

  test '+' do
    assert_equal undefined, undefined + Number.new(3)
    assert_equal undefined, 3 + undefined
  end

  test '-' do
    assert_equal undefined, undefined - Number.new(3)
    assert_equal undefined, 3 - undefined
  end

  test '*' do
    assert_equal undefined, undefined * Number.new(3)
    assert_equal undefined, 3 * undefined
  end

  test '/' do
    assert_equal undefined, undefined / Number.new(3)
    assert_equal undefined, 3 / undefined
  end

  test '^' do
    assert_equal undefined, undefined ^ Number.new(3)
    assert_equal undefined, 3 ^ undefined
  end

  test '**' do
    assert_equal undefined, undefined**Number.new(3)
    assert_equal undefined, 3**undefined
  end
end
