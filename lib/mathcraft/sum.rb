# frozen_string_literal: true

module Mathcraft
  class Sum < Immediate
    attr_reader :terms

    # Canonical form could use a hash of { variables => term }, then when
    # adding a new polynomial we can quickly recognize and combine like terms.
    def initialize(*terms)
      terms = terms.map { |t| craft(t).to_immediate }

      unless terms.all?(&:term?)
        raise "Cannot create sum from non-terms #{terms.inspect}"
      end

      @terms = terms.each_with_object(Hash.new(Term.zero)) do |term, h|
        h[term.variables] += term
      end
      @terms.reject! { |k, v| v.zero? }

      @terms = { {} => Term.zero } if @terms.empty?
    end

    def -@
      Sum.new(*terms.values.map(&:-@))
    end

    def +@
      self
    end

    def +(other)
      other = craft(other).to_immediate

      return self if other == Term.zero
      return other if self == Term.zero

      case other
      when Undefined then undefined
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

      return undefined if other.undefined?
      return Term.zero if other == Term.zero || self == Term.zero
      return self if other == Term.one
      return other if self == Term.one

      new_terms = terms.values.product(other.terms.values).map { |a, b| a * b }
      Sum.new(*new_terms)
    end

    def /(other)
      other = craft(other)

      return Term.one if other == self
      return undefined if other.undefined?
      return undefined if other.zero?
      return self if other.one?
      return Term.zero if self == Term.zero

      if other.rational?
        Term.new(other.to_r, {}).reciprocal * self
      else
        # TODO This is lazy. For multiplication we distribute. We could
        # distribute here, too, but then we'd likely need to produce a sum of
        # ratios. Since sum currently doesn't support ratios (bad!) this is a
        # problem.
        Ratio.new(self, other)
      end
    end

    def **(other)
      other = craft(other)

      # TODO Is using rational here correct? We want to catch negative
      # integers, for sure, but does the behavior hold for negative fractions?
      if self == Term.zero && other.rational? && other.to_r.negative?
        return undefined
      end
      return undefined if other.undefined?
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
      [self, craft(other).to_immediate]
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
      other = craft(other).to_immediate

      other = Sum.new(other) unless other.sum?

      terms.values.sort <=> other.terms.values.sort
    end

    def ==(other)
      (other.kind_of?(Sum) && terms == other.terms) ||
      (rational? && other.rational? && to_r == other.to_r)
    end

    def eql?(other)
      self == other
    end

    def hash
      terms.hash
    end

    def zero?
      rational? && to_r == 0
    end

    def one?
      rational? && to_r == 1
    end

    def rational?
      # Realistically this is only true with a single value, since multiple
      # rational values should be combined as we go.
      terms.values.all?(&:rational?)
    end

    def to_r
      terms.values.map(&:to_r).inject('+')
    end

    def to_term
      terms.values.first if terms.length == 1
    end

    def to_sum
      self
    end
  end
end
