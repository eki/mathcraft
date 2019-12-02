# frozen_string_literal: true

module Mathcraft
  class Lazy < Object
    def +(other)
      Expression.new('+', self, other)
    end

    def -(other)
      Expression.new('-', self, other)
    end

    def *(other)
      Expression.new('*', self, other)
    end

    def /(other)
      Expression.new('/', self, other)
    end

    def **(other)
      Expression.new('^', self, other)
    end

    alias ^ **

    def coerce(other)
      [craft(other), self]
    end

    def <=>(other)
      other = craft(other)

      [type, value] <=> [other.type, other.value]
    rescue
      nil
    end

    def eql?(other)
      self == other
    end

    def hash
      value.hash
    end

    def to_s
      value.to_s
    end

    def inspect
      value.to_s
    end

    def to_lazy
      self
    end
  end
end
