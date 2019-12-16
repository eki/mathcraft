# frozen_string_literal: true

require_relative '../test_helper'

class SolveTest < Minitest::Test
  include Mathcraft

  def assert_solved(expected, other)
    expected, other = craft(expected), craft(other)

    assert_equal expected, other.solve,
      "Expected #{other.inspect} to simplify to #{expected.inspect}"
  end

  test 'really easy' do
    assert_solved 'x = 3', 'x = 2 + 1'
    assert_solved 'x = -2', 'x = y - y - 2'
    assert_solved 'x = 10', 'x = 10x / x'
  end

  test 'move unlike terms to other side' do
    assert_solved 'x = 1', 'x - 2 = -1'
    assert_solved 'x = 10', '10 = x'
    assert_solved 'x = 13', '10 = x - 3'
    assert_solved 'x = -7', '10 = 3 - x'
  end

  test 'divide out terms' do
    assert_solved 'x = 2', '2x = 4'
    assert_solved 'x = 5', 'x = 3x - 10'
    assert_solved 'x = 1 / (yz)', 'xyz = 1'
  end

  test 'something more complicated' do
    assert_solved 'y = x', '(4y - 8) / (2x - 4) = 2'
    assert_solved 'x = 5', '3x / (x - 2) = (3x + 10) / x'
    assert_solved 'x = 20', '3x / (x - 2) = (3x + 10) / (x + 1)'
    assert_solved 'x = 28', '(1/4)x - 3 = 4'
  end

  test 'multiple solutions' do
    eq = craft('(x + 2)(2x -1) = 0')
    solutions = eq.solve
    assert_equal 2, solutions.length
    assert_equal [craft('x = 1 / 2'), craft('x = -2')], solutions.sort

    eq = craft('(7 - 2y)(5 + y) = 0')
    solutions = eq.solve
    assert_equal 2, solutions.length
    assert_equal [craft('y = 7 / 2'), craft('y = -5')], solutions.sort

    eq = craft('x^4 - 15x^2 - 10x + 24 = 0')
    solutions = eq.solve
    assert_equal 4, solutions.length
    assert_equal [craft('x = -3'), craft('x = -2'), craft('x = 1'),
      craft('x = 4')], solutions.sort

    eq = craft('(x + 1)(2x - 2) = 0')
    solutions = eq.solve
    assert_equal 2, solutions.length
    assert_equal [craft('x = -1'), craft('x = 1')], solutions.sort

    # Fractional coefficients on a polynomial
    eq = craft('(3/79)x^2 + (30/79)x + 63/79 = 0')
    solutions = eq.solve
    assert_equal 2, solutions.length
    assert_equal [craft('x = -7'), craft('x = -3')], solutions.sort
  end

  test 'solution is all real numbers' do
    eq = craft('5(- 3x - 2) - (x - 3) = -4(4x + 5) + 13')
    solutions = eq.solve
    assert_equal true, solutions
  end

  test 'no solution' do
    eq = craft('3x / (x + 1) + 6 = -3 / (x + 1)')
    solution = eq.solve
    refute solution, "Expected no solution to #{eq}, got #{solution}"
  end

  # TODO We'll also want to deal with exponents in this test (besides those
  # that arise naturally from multiplying by x.
  test 'random' do
    ops = %i(+ - * /)
    numbers = (1..10).to_a
    variables = %w(x y z)
    terms = numbers + variables

    20.times do
      eq = craft('x = 1')
      10.times do
        eq = eq.send(ops.sample, terms.sample)
      end
      assert_equal craft('x = 1'), solution = eq.solve,
        "Expected #{eq} to solve to x = 1, but was: #{solution}"
    end
  end
end
