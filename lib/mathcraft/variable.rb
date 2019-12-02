# frozen_string_literal: true

module Mathcraft
  class Variable < Lazy
    attr_reader :value

    def initialize(value)
      @value = value.to_s
    end

    def term?
      true
    end

    def to_term
      Term.new(1, self => 1)
    end

    def to_immediate
      to_term
    end

    def to_lazy
      self
    end
  end
end
