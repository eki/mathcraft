# frozen_string_literal: true

require 'mathcraft/version'

# Base for everything?
require 'mathcraft/types'
require 'mathcraft/object'

# Lazy
require 'mathcraft/lazy'
require 'mathcraft/variable'    # => term
require 'mathcraft/number'      # => term
require 'mathcraft/expression'  # => term or sum or ratio

# Immediate
require 'mathcraft/immediate'
require 'mathcraft/undefined'
require 'mathcraft/term'   # multiplication
require 'mathcraft/sum'    # addition
require 'mathcraft/ratio'  # division

require 'mathcraft/parser'

module Mathcraft
  extend self

  def craft(object)
    case object
    when Lazy then object
    when Immediate then object
    when Rational
      if object.denominator == 1
        craft(object.numerator)
      else
        craft(object.numerator) / object.denominator
      end
    when Numeric then Number.new(object)
    when Symbol then craft(object.to_s)
    when String then Parser.new(object).parse
    else raise "Don't know what to do with #{object.inspect} (#{object.class})"
    end
  end

  def undefined
    @undefined ||= Undefined::UNDEFINED
  end
end
