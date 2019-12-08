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
        eq = move_everything_not_variable_to_the_right(eq, variable)
        eq = divide_out_lowest_common_variable(eq, variable)
        eq = undo_multiplication(eq, variable)
        eq = undo_division(eq, variable)
      end

      @solution = eq
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

        im /= term
      end

      im.to_lazy
    end

    def undo_division(equation, variable)
      im = equation.to_immediate

      if im.left.ratio?
        im *= im.left.denominator
      end

      im.to_lazy
    end
  end
end
