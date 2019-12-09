# frozen_string_literal: true

module Mathcraft
  class Number < Lazy
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def positive?
      value > 0
    end

    def negative?
      value < 0
    end

    def zero?
      value == 0
    end

    def rational?
      true
    end

    def to_r
      Rational(value, 1)
    end

    def to_numeric
      value
    end

    def to_immediate
      Term.new(value, {})
    end

    def atoms
      [self]
    end

    def factors
      ary = []
      1.upto(Math.sqrt(value)).each do |i|
        if value % i == 0
          ary << i
          ary << value / i
        end
      end
      ary.sort.uniq
    end
  end
end
