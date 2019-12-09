# frozen_string_literal: true

module Mathcraft
  class Solver
    attr_reader :equation, :variable

    def initialize(equation, variable)
      @equation, @variable = equation, variable
    end

    def solution
      return @solution if defined?(@solution)

      eq = equation
      last = nil
      n = 0

      until eq == last
        n += 1
        raise 'Possible infinite loop!' if n > 10

        last = eq
        eq = move_everything_to_the_left(eq)

        return solve_poly(eq, variable) if solve_poly?(eq, variable)

        eq = move_everything_not_variable_to_the_right(eq, variable)
        eq = divide_out_lowest_common_variable(eq, variable)
        eq = undo_multiplication(eq, variable)
        eq = undo_division(eq, variable)
      end

      return true if eq.left == eq.right # all numbers are solutions (?)

      @solution = eq
      @solution = nil unless check
      @solution
    end

    def solve_poly(eq, variable)
      if factors = eq.left.to_immediate.factors.map(&:to_lazy)
        factors.select! { |f| f.atoms.include?(variable) }
        factors.map do |f|
          Equation.new(f.to_lazy, Mathcraft.craft(0)).solve(variable)
        end
      end
    end

    def solve_poly?(eq, variable)
      im = eq.to_immediate
      im.left.sum? && im.left.polynomial? && im.right == Term.zero &&
      im.left.factors
    end

    def check
      eq = equation.substitute(solution.left, solution.right).to_immediate
      !eq.left.undefined? && !eq.right.undefined? && eq.left == eq.right
    end

    def move_everything_to_the_left(equation)
      (equation.to_immediate - equation.right).to_lazy
    end

    def move_everything_not_variable_to_the_right(equation, variable)
      im = equation.to_immediate

      if im.left.sum?
        im.left.terms.values.each do |t|
          im += -t unless t.to_lazy.atoms.include?(variable)
        end
      end

      im.to_lazy
    end

    def divide_out_lowest_common_variable(equation, variable)
      im = equation.to_immediate

      if im.left.sum?
        lowest = nil

        im.left.terms.values.each do |t|
          return equation unless t.term?

          exp = t.variables[variable]

          return equation unless exp.rational?

          lowest ||= exp
          lowest = exp if exp.to_r < lowest.to_r
        end

        im /= Term.new(1, variable => lowest)
      end

      im.to_lazy
    end

    def undo_multiplication(equation, variable)
      im = equation.to_immediate

      if im.left.term?
        term = Term.new(im.left.coefficient,
          im.left.variables.reject { |k, v| k == variable })

        im /= term unless term == Term.zero
      end

      im.to_lazy
    end

    def undo_division(equation, variable)
      im = equation.to_immediate

      ratio = im.left if im.left.ratio?
      ratio = im.left.terms.values.find(&:ratio?) if im.left.sum?

      if ratio
        im *= ratio.denominator
      end

      im.to_lazy
    end
  end
end
