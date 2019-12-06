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

    def solve
      # Instead of working *from* the immediate, look at the lazy expression
      # tree because it's more easily treated as divide and conquer... if the
      # variable we're solving for is on one half of the tree and not the
      # other, apply the opposite operator to that other side to remove it from
      # that side.  For example, solving for x, (+ x (+ y (* z 3))) at the very
      # top we can see we should take take half the tree in one step and apply
      # subtract (+ y (* z 3)) from both sides.
      eq = to_immediate.to_lazy
      x = eq.left.atoms.find(&:variable?) || eq.right.atoms.find(&:variable?)
      i = 0

      until (eq.left == x && !eq.right.atoms.include?(x)) || i > 100
        i += 1

        eq = Equation.new(eq.right, eq.left) if eq.right.atoms.include?(x)
        im = eq.to_immediate

        if eq.right.expression? && eq.right.atoms.include?(x)
          case eq.right.operator
          when '+'
            eq.right.args.each do |arg|
              im -= arg if arg.atoms.include?(x)
            end
            eq = im.to_lazy
            next
          when '-'
            if eq.right.args[0].atoms.include?(x)
              im -= eq.right.args[0]
            elsif eq.right.args[1].atoms.include?(x)
              im += eq.right.args[1]
            end
            eq = im.to_lazy
            next
          when '*'
            eq.right.args.each do |arg|
              im /= arg if arg.atoms.include?(x)
            end
            next
          when '/'
            if eq.right.args[0].atoms.include?(x)
              im *= eq.right.args[1]
            elsif eq.right.args[1].atoms.include?(x)
              im *= eq.right.args[1]
            end
            eq = im.to_lazy
            next
          end
        elsif eq.left.expression?
          case eq.left.operator
          when '+'
            eq.left.args.each do |arg|
              im -= arg unless arg.atoms.include?(x)
            end
          when '-'
            if !eq.left.args[0].atoms.include?(x)
              im -= eq.left.args[0]
            elsif !eq.left.args[1].atoms.include?(x)
              im += eq.left.args[1]
            end
          when '*'
            eq.left.args.each do |arg|
              im /= arg unless arg.atoms.include?(x)
            end
          when '/'
            if !eq.left.args[0].atoms.include?(x)
              im *= eq.left.args[1]
            elsif !eq.left.args[1].atoms.include?(x)
              im *= eq.left.args[1]
            end
          end
        end

        eq = im.to_lazy
      end

      eq
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
  end
end
