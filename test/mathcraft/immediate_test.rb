# frozen_string_literal: true

require_relative '../test_helper'

class ImmediateTest < Minitest::Test
  include Mathcraft

  # Series of tests that attempt to show that different combinations of
  # operators, etc, only produce the most minimal immediate representations.
  # These tests are possibly redundant with other unit tests, but primarily
  # concern themselves with type checking.

  def assert_term(obj)
    assert obj.term?, "Expected #{obj.inspect} to be Term, not #{obj.class}"
  end

  def assert_sum(obj)
    assert obj.sum?, "Expected #{obj.inspect} to be Sum, not #{obj.class}"
  end

  def assert_ratio(obj)
    assert obj.ratio?, "Expected #{obj.inspect} to be Ratio, not #{obj.class}"
  end

  def n
    @n ||= craft!(12).tap { |num| assert_term num }
  end

  def x
    @x ||= craft!('x').tap { |var| assert_term var }
  end

  def y
    @y ||= craft!('y').tap { |var| assert_term var }
  end

  test 'Number#to_immediate' do
    assert_term Number.new(3).to_immediate
  end

  test 'Variable#to_immediate' do
    assert_term Variable.new('x').to_immediate
  end

  test 'unary -term' do
    assert_term(-x)
    assert_term(-n)
    assert_term(-(2 * x))
  end

  test 'unary +term' do
    assert_term(+x)
    assert_term(+n)
    assert_term(+(2 * x))
  end

  test 'add like terms' do
    assert_term x + x
    assert_term n + 4
  end

  test 'add unlike terms' do
    assert_sum x + y
    assert_sum x + 3
  end

  test 'subtract like terms' do
    assert_term x - x
    assert_term n - 4
  end

  test 'subtract unlike terms' do
    assert_sum x - y
    assert_sum x - 3
  end

  test 'multiply terms' do
    assert_term x * x
    assert_term x * y
    assert_term x * 3
  end

  test 'multiply term by reciprocal is term' do
    assert_term x * (1 / x)
  end

  test 'dividing like terms' do
    assert_term x / x
    assert_term x / 3 # changes coefficient to 1/3
    assert_term 2 * x / x
    assert_term x * x / x
    assert_term n / 1
    assert_term n / 3
    assert_term n / 7 # coefficient can be rational
  end

  test 'dividing unlike terms' do
    assert_ratio x / y
  end

  test 'dividing partially unlike terms' do
    assert_ratio((2 * x) / (2 * y))
    assert_equal craft('x/y'), craft!('(2x)/(2y)')
  end

  test 'term to power of term is term' do
    assert_term x**x
    assert_term x**2
    assert_term x**y
    assert_term n**x
    assert_term n**2
    assert_term((2 * x)**3)
    assert_term((2 * x)**y)
  end

  test 'unary -sum' do
    assert_sum(-(x + y))
    assert_sum(-(x + 3))
  end

  test 'unary +sum' do
    assert_sum(+(x + y))
    assert_sum(+(x + 3))
  end

  test 'add sums reduce to term if reduce to one element' do
    assert_term x + -x
    assert_term n + -n
    assert_term((x + y) + (-x + -y))
    assert_term((2 * x + 1) + (-2 * x + -1))
  end

  test 'add sums do not reduce to term if multiple elements' do
    assert_sum((x + y) + (x + n))
    assert_sum((2 * x + 1) + (-2 * x + y))
  end

  test 'subtract sum reduce to term if reduce to one element' do
    assert_term x - x
    assert_term n - n
    assert_term((x + y) - (x + y))
    assert_term((2 * x + 1) - (2 * x + 1))
  end

  test 'subtract sums do not reduce to term if multiple elements' do
    assert_sum((x + y) - (x + n))
    assert_sum((2 * x + 1) - (2 * x + y))
  end

  test 'multiply sum by zero reduces to term' do
    assert_term((x + y) * 0)
    assert_term((x + n) * 0)
    assert_term(0 * (x + y))
    assert_term(0 * (x + n))
  end

  test 'multiply sum by one is sum' do
    assert_sum((x + y) * 1)
    assert_sum((x + n) * 1)
    assert_sum(1 * (x + y))
    assert_sum(1 * (x + n))
  end

  test 'multiply sum by term is sum' do
    assert_sum((x + y) * 2)
    assert_sum((x + y) * x)
    assert_sum((x + y) * y)
    assert_sum((x + n) * n)
    assert_sum((x + n) * x)
    assert_sum((x + n) * y)
  end

  test 'multiply sum by ratio is sum' do
    assert_sum((x + y) * (1 / x))
    assert_sum((x + y) * (1 / y))
  end

  test 'multiply sum by reciprocal is term' do
    assert_term((x + y) * (1 / (x + y)))
  end

  test 'multiply sum by sum is sum' do
    assert_sum((x + y) * (x + n))
    assert_sum((x + 3) * (x + 4))
    assert_sum((x + 1) * (x - 1))
  end

  test 'divide sum by zero is undefined' do
    assert_equal undefined, (x + y) / 0
  end

  test 'divide sum by one is sum' do
    assert_sum((x + y) / 1)
    assert_sum((x + n) / 1)
  end

  test 'divide sum by like sum is term' do
    assert_term((x + y) / (x + y))
    assert_term((2 * x + 2 * y) / (x + y))
  end

  test 'divide sum (poly) by sum (factor) is sum' do
    assert_sum((x**2 - 1) / (x + 1))
    assert_sum((x**2 - 1) / (x - 1))
  end

  test 'divide sum by term (factor) is sum' do
    assert_sum((2 * x + 4) / 2)
  end

  test 'divide sum by unlike sum is ratio' do
    assert_ratio((x + y) / (x + n))
    assert_ratio((n + y) / (x + n))
    assert_ratio((n + y) / (x + y))
  end

  test 'sum to power of term is sum' do
    assert_sum((x + y)**2)
    assert_sum((x + n)**2)
  end

  test 'sum to unknown power is term' do
    assert(((x + n)**y).term?)
  end

  test 'unary -ratio is ratio' do
    assert_ratio(-(x / y))
    assert_ratio(-(n / x))
  end

  test 'ratio + zero is ratio' do
    assert_ratio((x / y) + 0)
    assert_ratio(0 + (x / y))
  end

  test 'ratio + like is ratio' do
    assert_ratio((x / y) + (n / y))
    assert_ratio((n / y) + (3 / y))
  end

  test 'ratio + unlike is sum' do
    assert_sum((x / y) + (n / x))
    assert_sum((n / y) + (3 / x))
  end

  test 'ratio - like is ratio' do
    assert_ratio((x / y) - (n / y))
    assert_ratio((n / y) - (3 / y))
  end

  test 'ratio - unlike is sum' do
    assert_sum((x / y) - (n / x))
    assert_sum((n / y) - (3 / x))
  end

  test 'ratio * one is ratio' do
    assert_ratio((x / y) * 1)
    assert_ratio(1 * (x / y))
    assert_ratio((n / y) * 1)
  end

  test 'ratio * zero is term' do
    assert_term((x / y) * 0)
    assert_term((n / y) * 0)
    assert_term((x / n) * 0)
  end

  test 'ratio * cancels to term' do
    assert_term((x / y) * y)
    assert_term((x / n) * n)
  end

  test 'ratio * cancels to sum' do
    assert_term((x / (y + 3)) * (y + 3))
  end

  test 'ratio * cancels to sum' do
    assert_sum((x + n) / (x + y) * (x + y))
  end

  test 'ratio * is ratio' do
    assert_ratio((x / y) * (x / y))
  end

  test 'ratio * reciprocal is term' do
    assert_term((x / y) * (y / x))
  end

  test 'ratio / 0 is undefined' do
    assert_equal undefined, (x / y) / 0
  end

  test 'ratio / by self is term' do
    assert_term((x / y) / (x / y))
  end

  test 'ratio / by one is ratio' do
    assert_ratio((x / y) / 1)
  end

  test 'ratio / by term is ratio' do
    assert_ratio((x / y) / n)
    assert_ratio((x / y) / y)
  end

  test 'ratio / sum is ratio' do
    assert_ratio((x / y) / (x + n))
    assert_ratio((x / (y + 3)) / (y + 3))
  end

  test 'ratio / ratio can cancel to term' do
    assert_term((x / y) / (x / y))
    assert_term((2 * x / 2 * y) / (x / y))
    assert_term((x / y) / (x * 2 / y * 3))
  end

  test 'ratio / ratio is ratio' do
    assert_ratio((x / y) / (y / x))
    assert_ratio((n / y) / (y / x))
    assert_ratio((x / y) / (y / (n * x)))
    assert_ratio((x / y) / (y / (n + x)))
  end

  test 'ratio ** term is ratio' do
    assert_ratio((x / y)**2)
    assert_ratio((x / y)**n)
    assert_ratio((n / y)**x)
    assert_ratio((n / y)**1)
  end

  test 'ratio ** 0 is term' do
    assert_term((x / y)**0)
    assert_term((n / y)**0)
  end
end
