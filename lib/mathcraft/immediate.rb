# frozen_string_literal: true

module Mathcraft
  class Immediate < Object
    def to_immediate
      self
    end

    def coerce(other)
      [craft!(other), self]
    end
  end
end
