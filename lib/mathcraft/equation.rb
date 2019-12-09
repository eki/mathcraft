# frozen_string_literal: true

module Mathcraft
  class Equation < Object
    attr_reader :left, :right

    def initialize(left, right)
      @left, @right = left, right
    end

    def -@
      Equation.new(-left, -right)
    end

    def +@
      self
    end

    def +(other)
      Equation.new(left + other, right + other)
    end

    def -(other)
      Equation.new(left - other, right - other)
    end

    def *(other)
      Equation.new(left * other, right * other)
    end

    def /(other)
      Equation.new(left / other, right / other)
    end

    def **(other)
      Equation.new(left**other, right**other)
    end

    alias ^ **

    def substitute(a, b)
      eq = to_lazy
      Equation.new(eq.left.substitute(a, b), eq.right.substitute(a, b))
    end

    def to_lazy
      return self if lazy?

      Equation.new(left.to_lazy, right.to_lazy)
    end

    def to_immediate
      return self if immediate?

      Equation.new(left.to_immediate, right.to_immediate)
    end

    def lazy?
      left.lazy? && right.lazy?
    end

    def immediate?
      left.immediate? && right.immediate?
    end

    def coerce(other)
      [self, lazy? ? craft(other) : craft!(other)]
    end

    def inspect
      "(= #{left.inspect} #{right.inspect})"
    end

    def to_s
      "#{left} = #{right}"
    end

    def <=>(other)
      return nil unless other.kind_of?(Equation)

      [left, right] <=> [other.left, other.right]
    end

    def eql?(other)
      self == other
    end

    def hash
      [left, right].hash
    end

    def solve(variable=nil)
      variable ||= left.to_lazy.atoms.find(&:variable?)
      variable ||= right.to_lazy.atoms.find(&:variable?)
      variable = craft(variable)

      raise ArgumentError unless variable&.variable?

      Solver.new(self, variable).solution
    end
  end
end
