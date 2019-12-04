# frozen_string_literal: true

module Mathcraft
  class Parser
    attr_reader :scanner

    def initialize(input)
      @scanner = Scanner.new(input)
    end

    def parse
      left = parse_expression
      skip_whitespace

      if scan(/=/)
        skip_whitespace

        right = parse_expression

        error 'Expected right side of equation' unless right

        left = Equation.new(left, right)
      end

      left
    end

    def parse_expression(precedence=0)
      skip_whitespace

      error 'Expected value' unless left = parse_atom

      skip_whitespace

      while remaining_expression? && precedence < prec(check_operator)
        error 'Expected operator' unless op = parse_operator

        left = Expression.new(op, left, parse_expression(prec(op) - assoc(op)))
      end

      left
    end

    class Error < RuntimeError
    end

    def error(msg='Parse error')
      raise Error, msg
    end

    def remaining_expression?
      scanner.remaining? && !scanner.check(/\s*(\)|=|\z)/)
    end

    def assoc(operator)
      case operator
      when '^' then 1
      else 0
      end
    end

    PRECEDENCE = {
      '^' => 30,
      '*' => 20,
      '/' => 20,
      '+' => 10,
      '-' => 10
    }.freeze

    def prec(operator)
      PRECEDENCE[operator]
    end

    def check_normal_op
      scanner.check(%r{\s*[*+-/^]})
    end

    def check_operator
      unless op = check_normal_op || implicit_operator
        error 'Expected operator'
      end

      op&.strip
    end

    def parse_operator
      scan(%r{[*+-/^]}) || implicit_operator
    end

    def check_atom
      scanner.check(/\s*[a-zA-Z\d\(]/)
    end

    def implicit_operator
      '*' if check_atom
    end

    def parse_atom
      parse_number || parse_variable || parse_parenthesized_expression ||
      parse_unary_minus
    end

    def parse_unary_minus
      if scan(/-/)
        skip_whitespace

        expr = parse_expression(prec('^') - 5)
        expr.number? && expr.positive? ? Number.new(-expr.value) : -expr
      end
    end

    def parse_parenthesized_expression
      if scan(/\(/)
        expr = parse_expression

        skip_whitespace
        error 'Expected closing paren' unless scan(/\)/)

        expr
      end
    end

    def parse_number
      if s = scan(/\d+(?:\.\d+)?/)
        Number.new(s['.'] ? s.to_f : s.to_i)
      end
    end

    def parse_variable
      if s = scan(/[a-zA-Z]/)
        Variable.new(s)
      end
    end

    def skip_whitespace
      scan(/\s*/)
    end

    def scan(regexp)
      scanner.scan(regexp)
    end

    class Scanner
      attr_reader :input, :remaining, :position, :match, :match_data

      def initialize(input)
        @input = input
        @position = 0
        @remaining = @input
      end

      def scan(regex)
        if (md = regex.match(remaining)) && md.begin(0) == 0
          @position += md[0].length
          @remaining = input.slice(position, input.length - position)
          @match_data = md
          @match = md[0]
        end
      end

      def check(regex)
        md = regex.match(remaining)
        md && md.begin(0) == 0 && md[0]
      end

      def remaining?
        !remaining.empty?
      end
    end
  end
end
