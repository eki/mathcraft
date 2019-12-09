# frozen_string_literal: true

module Mathcraft
  class Ratio < Immediate
    attr_reader :numerator, :denominator

    # Ideally this would only be used for sums, but maybe it'll include terms,
    # too? We should also attempt to simplify these ratios. For example,
    # something like (x^2 - 1) / (x - 1) => (x + 1) / 1 => x + 1 (when
    # converting back to an expression in the last step).
    def initialize(numerator, denominator)
      @numerator, @denominator = craft!(numerator), craft!(denominator)

      if @denominator.zero?
        @numerator = undefined
        @denominator = undefined
      elsif @numerator.rational? && @denominator.rational?
        r = @numerator.to_r / @denominator.to_r
        @numerator = craft!(r.numerator)
        @denominator = craft!(r.denominator)
      end
    end

    def -@
      Ratio.new(-numerator, denominator)
    end

    def +@
      self
    end

    def +(other)
      other = craft!(other)

      return undefined if other.undefined?
      return self if other.term? && other.zero?

      if other.term? && denominator == Term.one
        return Ratio.new(numerator + other, denominator).downgrade
      elsif other.ratio? && other.denominator == denominator
        return Ratio.new(numerator + other.numerator, denominator).downgrade
      end

      Sum.new(self, other)
    end

    def -(other)
      self + -other
    end

    def *(other)
      other = craft!(other)

      return undefined if other.undefined?
      return self if other.term? && other.one?
      return Term.zero if other.term? && other.zero?

      # This will always be more efficient, but is currently necessary because
      # ratios do not know how to simplify when there are unknowns involved
      # (especially sums).
      return numerator if other == denominator

      other = Ratio.new(other, Term.one) unless other.ratio?

      Ratio.new(numerator * other.numerator, denominator * other.denominator).
        downgrade
    end

    def /(other)
      other = craft!(other)

      return undefined if other.undefined?
      return undefined if other.term? && other.zero?
      return Term.one if other == self
      return self if other == Term.one
      return self * other.reciprocal if other.term?

      other = Ratio.new(other, Term.one) if other.term? || other.sum?

      return self * other.reciprocal if other.ratio?
    end

    def **(other)
      other = craft!(other)

      return undefined if other.undefined?
      return Term.one if other.term? && other.zero?
      return self if other.term? && other.one?
      return Ratio.new(numerator**other, denominator**other) if other.term?

      nil
    end

    alias ^ **

    def coerce(other)
      [self, craft!(other)]
    end

    def inspect
      "(ratio #{numerator.inspect} over #{denominator.inspect})"
    end

    def to_lazy
      if denominator == Term.one
        numerator.to_lazy
      else
        numerator.to_lazy / denominator.to_lazy
      end
    end

    def to_s
      to_lazy.to_s
    end

    def <=>(other)
      other = craft!(other)
      other = other if other.ratio?
      other = Ratio.new(other, Term.one) if other.sum? || other.term?

      return nil unless other.ratio?

      [denominator, numerator] <=> [other.denominator, other.numerator]
    end

    def ==(other)
      other.kind_of?(Ratio) && numerator == other.numerator &&
      denominator == other.denominator
    end

    def eql?(other)
      self == other
    end

    def hash
      [numerator, denominator].hash
    end

    def zero?
      numerator.zero?
    end

    def like?(other)
      other.ratio? && likeness == other.likeness
    end

    def likeness
      Ratio.new(Term.one, denominator)
    end

    def reciprocal
      Ratio.new(denominator, numerator)
    end

    def to_term
      if denominator.rational? && numerator.term?
        numerator / denominator
      end
    end

    def to_sum
      numerator.to_sum if denominator == Term.one && numerator.sum?
    end

    def to_zero
      Term.zero if numerator == Term.zero
    end

    def to_one
      Term.one if numerator == denominator
    end

    def downgrade
      to_zero || to_one || to_sum || to_term || self
    end
  end
end
