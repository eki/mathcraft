# frozen_string_literal: true

require_relative '../test_helper'

class NumberTest < Minitest::Test
  include Mathcraft

  test 'new' do
    assert_equal 3, Number.new(3).value
    assert_equal 4.2, Number.new(4.2).value
    assert_equal 0, Number.new(0).value
    assert_equal(-27, Number.new(-27).value)
  end

  test 'to_s' do
    assert_equal '7', Number.new(7).to_s
    assert_equal '1.2', Number.new(1.2).to_s
  end

  test 'inspect' do
    assert_equal '10', Number.new(10).inspect
    assert_equal '-2', Number.new(-2).inspect
  end

  test '==' do
    assert_equal Number.new(4), Number.new(4)
    assert_equal Number.new(-3), Number.new(-3)

    refute_equal Number.new(-3), Number.new(3)
  end

  test 'eql?' do
    assert Number.new(7).eql?(Number.new(7))
    assert Number.new(0).eql?(Number.new(0))
    refute Number.new(0).eql?(Number.new(-1))
  end

  test 'hash' do
    assert_equal Number.new(7).hash, Number.new(7).hash
    assert_equal Number.new(0).hash, Number.new(0).hash
    refute_equal Number.new(0).hash, Number.new(-1).hash
  end

  test '<=>' do
    # rubocop:disable Lint/UselessComparison
    assert_equal 0, Number.new(3) <=> Number.new(3)
    assert_equal(-1, Number.new(2) <=> Number.new(3))
    assert_equal 1, Number.new(3) <=> Number.new(2)
    # rubocop:enable Lint/UselessComparison
  end

  test 'sort' do
    assert_equal [Number.new(-1), Number.new(0), Number.new(1)],
      [Number.new(1), Number.new(-1), Number.new(0)].sort
  end

  test 'type' do
    assert_equal 'number', Number.new(12).type
  end

  test 'number?' do
    assert Number.new(20).number?
  end

  test 'variable?' do
    refute Number.new(-3).variable?
  end

  test 'expression?' do
    refute Number.new(72).expression?
  end

  test 'lazy?' do
    assert Number.new(3).lazy?
  end

  test 'immediate?' do
    refute Number.new(0).immediate?
  end

  test 'positive?' do
    refute Number.new(-1).positive?
    refute Number.new(0).positive?
    assert Number.new(1).positive?
  end

  test 'negative?' do
    assert Number.new(-1).negative?
    refute Number.new(0).negative?
    refute Number.new(1).negative?
  end

  test 'zero?' do
    refute Number.new(-1).zero?
    assert Number.new(0).zero?
    refute Number.new(1).zero?
  end

  test 'rational?' do
    assert Number.new(0).rational?
  end

  test 'to_r' do
    assert_equal 2r, Number.new(2).to_r
  end

  test 'to_numeric' do
    assert_equal 3, Number.new(3).to_numeric
  end

  test 'to_lazy' do
    number = Number.new(3)

    assert_equal number.object_id, number.to_lazy.object_id
  end

  test 'to_immediate' do
    assert_equal Term.new(1, {}), Number.new(1).to_immediate
  end
end
