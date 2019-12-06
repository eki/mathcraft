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

    def to_lazy
      self
    end

    def atoms
      [self]
    end
  end
end
