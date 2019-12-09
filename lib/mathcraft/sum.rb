# frozen_string_literal: true

module Mathcraft
  class Sum < Immediate
    attr_reader :terms

    # Canonical form could use a hash of { variables => term }, then when
    # adding a new polynomial we can quickly recognize and combine like terms.
    def initialize(*terms)
      terms = terms.map { |t| craft!(t) }
      terms = terms.map { |t| t.sum? ? t.terms.values : t }.flatten

      @terms = terms.each_with_object(Hash.new(Term.zero)) do |term, h|
        h[term.likeness] += term
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
      other = craft!(other)

      return self if other == Term.zero
      return other if self == Term.zero

      case other
      when Undefined then undefined
      when Term then Sum.new(*terms.values, other).downgrade
      when Ratio then Sum.new(*terms.values, other).downgrade
      when Sum then Sum.new(*terms.values, *other.terms.values).downgrade
      end
    end

    def -(other)
      self + -craft!(other)
    end

    def *(other)
      other = craft!(other)

      return undefined if other.undefined?
      return Term.zero if other == Term.zero || self == Term.zero
      return self if other == Term.one
      return other if self == Term.one

      new_terms = terms.values.map { |t| t * other }
      Sum.new(*new_terms).downgrade
    end

    def /(other)
      other = craft!(other)

      return Term.one if other == self
      return undefined if other.undefined?
      return undefined if other.zero?
      return self if other.one?
      return Term.zero if self == Term.zero

      if other.rational?
        Term.new(other.to_r, {}).reciprocal * self
      elsif other.term?
        # Distribute when dividing by a single term
        new_terms = terms.values.map { |t| t / other }
        Sum.new(*new_terms).downgrade
      elsif polynomial? && other.sum? && other.polynomial?
        poly_div(self, other)
      else
        # TODO Still punting on sum divided by sum
        Ratio.new(self, other)
      end
    end

    def **(other)
      other = craft!(other)

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
      [self, craft!(other)]
    end

    def inspect
      "(sum #{terms.inspect})"
    end

    def to_lazy
      return craft(0) if terms.empty?

      first, *rest = *terms.values.sort
      expr = first.to_lazy

      rest.each do |term|
        if leading_sign(term) == '+'
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
      other = craft!(other)

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

    def downgrade
      to_term || self
    end

    def polynomial?
      terms.values.all? do |term|
        term.term? && term.monomial?
      end
    end

    def degree
      return terms.values.map(&:degree).max if polynomial?
    end

    def lead
      terms.values.min
    end

    def constant
      terms.values.find(&:rational?) || Term.zero
    end

    # Use rational roots to try to find any factors.
    # TODO: Should we always return self if no factors are found?
    # Currently returns nil if multiple rational factors are not found.
    def factors
      return nil unless polynomial? && degree > 1

      return nil unless lead.coefficient.denominator == 1
      return nil unless constant&.coefficient&.denominator == 1

      lead_factors = craft(lead.coefficient.abs).factors
      constant_factors = craft(constant.coefficient.abs).factors

      possible_roots = constant_factors.product(lead_factors).
        map { |a, b| [Rational(-a, b), Rational(a, b)] }.flatten

      variable = lead.variables.keys.
        find { |v| lead.variables[v] == lead.degree }

      factors = []

      possible_roots.each do |root|
        if to_lazy.substitute(variable, root).to_immediate == Term.zero
          factors << craft!(variable) - root
        end
      end

      found = factors.inject('*')

      if found == self
        factors.length == 1 ? nil : factors
      elsif found
        factors + [self / found]
      end
    end

    private

    def leading_sign(object)
      return '-' if object.term? && object.negative?

      '+'
    end

    def poly_div(n, d)
      q, r = Term.zero, n

      while r != Term.zero && r.degree >= d.degree
        t = r.lead / d.lead

        return Ratio.new(n, d) if t.ratio?

        q += t
        r -= t * d
      end

      return Ratio.new(n, d) if r != Term.zero

      q + r
    end
  end
end
