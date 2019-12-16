# frozen_string_literal: true

module Mathcraft
  class Term < Immediate
    include Enumerable

    attr_reader :coefficient, :variables

    def initialize(coefficient, variables)
      @coefficient = coefficient.to_r
      @variables = {}

      unless coefficient == 0
        variables.each do |k, v|
          v = craft!(v)
          @variables[craft(k)] = v unless v == 0
        end
      end
    end

    def self.one
      @one ||= Term.new(1, {})
    end

    def self.zero
      @zero ||= Term.new(0, {})
    end

    def -@
      Term.new(-coefficient, variables)
    end

    def +@
      self
    end

    def +(other)
      other = craft!(other)

      return other if self == Term.zero
      return self if other == Term.zero

      # other should only be Sum or Ratio?
      return other + self unless other.term?

      if like?(other)
        Term.new(coefficient + other.coefficient, variables)
      else
        Sum.new(self, other)
      end
    end

    def -(other)
      self + -other
    end

    def *(other)
      other = craft!(other)

      return other if self == Term.one
      return self if other == Term.one
      return Term.zero if other == Term.zero || self == Term.zero
      return other * self if other.sum?

      # Sum and Ratio are the only things that are not terms, they will know
      # better how to do the multiplication
      return other * self unless other.term?

      new_coefficient = coefficient * other.coefficient
      new_variables = Hash.new(0).merge(variables)
      other.variables.each { |k, v| new_variables[k] += v }
      Term.new(new_coefficient, new_variables)
    end

    def /(other)
      other = craft!(other)

      return undefined if other == Term.zero
      return undefined if other.undefined?
      return Term.one if self == other
      return Term.zero if self == Term.zero
      return self if other == Term.one
      return Ratio.new(self, Term.one) / other if other.ratio?
      return Ratio.new(self, other) unless other.term?

      negative_exponents_to_ratio(self * other.reciprocal)
    end

    def **(other)
      other = craft!(other)

      return Term.one if other == Term.zero
      return undefined if other.undefined?
      return undefined if self == Term.zero && other.term? && other.negative?
      return Term.zero if self == Term.zero
      return Term.one if self == Term.one

      new_vars = variables.map { |k, v| [k, v * other] }.to_h
      new_coeff = 1r if coefficient == 1
      new_coeff = 0r if coefficient == 0
      new_coeff = coefficient**other.to_r if other.rational?
      unless new_coeff
        new_vars[coefficient] = other
        new_coeff = 1r
      end

      negative_exponents_to_ratio(Term.new(new_coeff, new_vars))
    end

    alias ^ **

    def inspect
      "(term #{coefficient} #{variables.inspect})"
    end

    def to_s
      to_lazy.to_s
    end

    def to_lazy
      return craft(0) if coefficient == 0
      return craft(1) if coefficient == 1 && variables.empty?

      ary = []
      ary << craft(coefficient) unless coefficient == 1

      variables.each do |var, exp|
        # TODO Use Term.one here instead of 1?
        ary << (exp == 1 ? var : var.to_lazy**exp.to_lazy)
      end

      ary.inject('*')
    end

    def to_r
      coefficient if rational?
    end

    def rational?
      variables.empty?
    end

    def <=>(other)
      other = craft!(other)

      if other.term?
        sort_key <=> other.sort_key
      elsif other.ratio?
        Ratio.new(self, Term.one) <=> other
      elsif other.sum?
        Sum.new(self) <=> other
      end
    end

    def eql?(other)
      self == other
    end

    def hash
      [coefficient, variables].hash
    end

    def positive?
      coefficient.positive?
    end

    def negative?
      coefficient.negative?
    end

    def one?
      self == Term.one
    end

    def zero?
      self == Term.zero
    end

    def degree
      variables.values.select(&:rational?).map(&:to_r).max || 0
    end

    def like?(other)
      other.term? && variables == other.variables
    end

    def likeness
      variables
    end

    def abs
      positive? ? self : -self
    end

    def monomial?
      variables.all? do |v, exp|
        exp.rational? && exp.positive? && exp.to_r.denominator == 1
      end
    end

    def lead
      self if monomial?
    end

    # Possibly the wrong "name"
    def gcd(other)
      return nil unless other.term? # ?

      c1 = coefficient.numerator if coefficient.denominator == 1
      c2 = other.coefficient.numerator if other.coefficient.denominator == 1

      if c1 && c2
        g = c1.gcd(c2)
      else
        g = [coefficient.abs, other.coefficient.abs].min
      end

      cv = {}
      variables.each do |v, exp|
        cv[v] = [exp.to_r, other.variables[v].to_r].min if other.variables[v]
      end

      Term.new(g, cv)
    end

    # Not the right term?
    def reciprocal
      coeff = Rational(coefficient.denominator, coefficient.numerator)
      vars = variables.map { |k, v| [k, -v] }.to_h
      Term.new(coeff, vars)
    end

    # Largest degree, longest list of variables, variables in alphabetic order,
    # with tie breakers on exponent, and lastly coefficient.
    def sort_key
      [-degree,
       -variables.length,
       # v is often a term, too, so we to convert to_r to avoid double negative
       variables.map { |k, v| [k, v.rational? ? -v.to_r : v] }.sort_by(&:first),
       -coefficient]
    end

    private

    def negative_exponents_to_ratio(term)
      neg_vars = term.variables.select { |k, v| v.negative? }

      return term if neg_vars.empty?

      top = Term.new(term.coefficient,
        (term.variables.to_a - neg_vars.to_a).to_h)
      bottom = Term.new(1, neg_vars).reciprocal

      # If the top is something like 1/3 (coefficient 1/3, no unknowns),
      # we'll preemptively simplify, so we don't have a "fraction" on the top
      # of our ratio.
      if top.rational? && (r = top.to_r) && r != 1 && r.numerator == 1
        bottom *= Term.new(r.denominator, {})
        top = Term.one
      end

      Ratio.new(top, bottom)
    end
  end
end
