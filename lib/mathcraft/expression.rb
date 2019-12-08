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
      # TODO Probably don't need to be this paranoid that something not-lazy
      # has been mixed into our expression tree..?
      map { |expr| expr == self ? self : expr.to_lazy }
    end

    def to_s
      left, right = args[0], args[1]

      if left.expression? && prec(left.operator) < prec(operator)
        left = "(#{left})"
      end

      if right.expression? &&
         prec(right.operator) <= prec(operator) - assoc(operator)

        right = "(#{right})"
      end

      if operator == '*' && left == '-1'
        left = '-'
      end

      case operator
      when %r{[+/-]} then [left, operator, right].join(' ')
      when '*' then [left, right].join
      when '^' then [left, operator, right].join
      else "#{operator}(#{args.join(', ')})"
      end
    end

    def inspect
      "(#{operator} #{args.map(&:inspect).join(' ')})"
    end

    private

    def prec(operator)
      Parser::PRECEDENCE[operator]
    end

    def assoc(operator)
      Parser::ASSOCIATIVITY[operator]
    end

    def op_to_ruby(op)
      op == '^' ? '**' : op
    end
  end
end
