# frozen_string_literal: true

module Mathcraft
  class Object
    include Comparable
    include Mathcraft
    include Types

    def -@
      -1 * self
    end

    def +@
      self
    end

    def eql?(other)
      self == other
    end
  end
end
