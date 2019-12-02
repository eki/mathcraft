# frozen_string_literal: true

module Mathcraft
  module Types
    def type
      self.class.name.split('::').last.downcase
    end

    %w(number variable expression term sum ratio undefined).each do |t|
      define_method(:"#{t}?") { type == t }
    end

    def lazy?
      kind_of?(Lazy)
    end

    def immediate?
      kind_of?(Immediate)
    end

    def rational?
      false
    end
  end
end
