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

    def term?
      true
    end

    def to_term
      Term.new(value, {})
    end

    def to_numeric
      value
    end

    def to_immediate
      to_term
    end

    def to_lazy
      self
    end
  end
end
