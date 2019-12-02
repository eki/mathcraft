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

    def ^(other)
      undefined
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

    UNDEFINED = new

    class << self
      private :new # rubocop:disable Style/AccessModifierDeclarations
    end
  end
end
