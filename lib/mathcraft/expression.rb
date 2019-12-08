# frozen_string_literal: true

module Mathcraft
  class Expression < Lazy
    include Enumerable

    attr_reader :operator, :args

    def initialize(operator, *args)
      @operator, @args = operator, args.map { |arg| craft(arg) }
    end

    def each(&block)
      args.each { |arg| arg.expression? ? arg.each(&block) : yield(arg) }
      yield self
    end

    def map(&block)
      expr = Expression.new(operator,
        *args.map { |arg| arg.expression? ? arg.map(&block) : yield(arg) })
      yield expr
    end

    def atoms
      args.map(&:atoms).flatten.uniq
    end

    def value
      [operator, *args]
    end

    def rational?
      args.all?(&:rational?)
    end

    def to_r
      super unless rational?

      to_numeric.to_r
    end

    def to_numeric
      super unless args.all?(&:rational?)

      r = args.map(&:to_r).inject(op_to_ruby(operator))

      r.denominator == 1 ? r.numerator : r
    end

    def to_immediate
      args.map(&:to_immediate).inject(op_to_ruby(operator))
    end

    def to_lazy
      map { |expr| expr == self ? self : expr.to_lazy }
    end

    # TODO There must be a better way to do this?
    def to_s
      left, right = args[0], args[1]
      case operator
      when %r{[+/-]}
        left = "(#{left})" if parenthesize?(left)
        right = "(#{right})" if parenthesize?(right, right: true)

        "#{left} #{operator} #{right}"
      when '*'
        ary = []
        ary << (left == -1 ? '-' : left)
        if parenthesize_right?(right)
          ary << '(' << right << ')'
        else
          ary << right
        end

        ary.map(&:to_s).join
      when '^' then "#{left}^#{right}"
      else "#{operator}(#{args.join(', ')})"
      end
    end

    def inspect
      "(#{operator} #{args.map(&:inspect).join(' ')})"
    end

    private

    def parenthesize?(expr, right: false)
      n = right ? -1 : 0
      expr.expression? &&
      Parser::PRECEDENCE[expr.operator] + n < Parser::PRECEDENCE[operator]
    end

    def parenthesize_right?(expr)
      expr.number? ||
      (expr.expression? && !(expr.operator == '^' && expr.args.first.variable?))
    end

    def op_to_ruby(op)
      op == '^' ? '**' : op
    end
  end
end
