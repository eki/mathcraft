# frozen_string_literal: true

module Mathcraft
  class Undefined < Immediate
    def -@
      undefined
    end

    def +@
      undefined
    end

    def +(other)
      undefined
    end

    def -(other)
      undefined
    end

    def *(other)
      undefined
    end

    def /(other)
      undefined
    end

    def **(other)
      undefined
    end

    alias ^ **

    def coerce(other)
      [self, other]
    end

    def value
      type
    end

    def to_s
      'undefined'
    end

    def inspect
      'undefined'
    end

    def to_lazy
      undefined
    end

    def to_immediate
      undefined
    end

    def positive?
      false
    end

    def negative?
      false
    end

    def zero?
      false
    end

    UNDEFINED = new

    class << self
      private :new # rubocop:disable Style/AccessModifierDeclarations
    end
  end
end
