# frozen_string_literal: true

module Mathcraft
  class Sum < Immediate
    attr_reader :terms

    # Canonical form could use a hash of { variables => term }, then when
    # adding a new polynomial we can quickly recognize and combine like terms.
    def initialize(*terms)
      @terms = terms.each_with_object(Hash.new(Term.zero)) do |term, h|
        h[term.variables] += term
      end
      @terms.reject! { |k, v| v.zero? }
    end

    def -@
      Sum.new(*terms.values.map(&:-@))
    end

    def +@
      self
    end

    def +(other)
      other = craft(other).to_immediate

      case other
      when Term then Sum.new(*terms.values, other)
      when Sum then Sum.new(*terms.values, *other.terms.values)
      else
        raise "Don't know how to add #{other} (#{other.class}) to #{self} (Sum)"
      end
    end

    def -(other)
      self + -craft(other).to_immediate
    end

    def *(other)
      other = craft(other).to_immediate
      other = Sum.new(other) if other.term?

      new_terms = terms.values.product(other.terms.values).map { |a, b| a * b }
      Sum.new(*new_terms)
    end

    def /(other)
      other = craft(other)

      return Term.one if other == self

      if other.term?
        other.reciprical * self
      else
        Ratio.new(self, other)
      end
    end

    def **(other)
      other = craft(other)

      return Term.one if other == Term.zero
      return self if other == Term.one
      return Term.zero if self == Term.zero
      return Term.one if self == Term.one
      return Term.one / self**-other if other.term? && other.negative?

      # TODO Clean up this code to expand (sum)^exp
      if other.rational? && (r = other.to_r) && r.positive? &&
         r.denominator == 1

        expr = self
        (r.to_i - 1).times { expr *= self }
        return expr
      end

      Expression.new('^', self, other)
    end

    alias ^ **

    def coerce(other)
      [self, craft(other).to_term]
    end

    def inspect
      "(sum #{terms.inspect})"
    end

    def to_lazy
      return craft(0) if terms.empty?

      first, *rest = *terms.values.sort
      expr = first.to_lazy

      rest.each do |term|
        if term.positive?
          expr += term.to_lazy
        else
          expr -= term.abs.to_lazy
        end
      end

      expr
    end

    def to_s
      to_lazy.to_s
    end

    def <=>(other)
      other = craft(other)

      if other.to_immediate.sum?
        terms <=> other.to_sum.terms
      elsif other.term?
        terms <=> Sum.new(other.to_term).terms
      end
    end

    def ==(other)
      other.kind_of?(Sum) && terms == other.terms
    end

    def zero?
      terms.empty?
    end

    def to_term
      terms.values.first if terms.length == 1
    end

    def to_sum
      self
    end
  end
end
