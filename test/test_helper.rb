# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'bundler'
Bundler.setup

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/test/'
  end
end

require 'mathcraft'

require 'minitest/boost'
require 'minitest/autorun'

class Minitest::Test
end

# Move this to Minitest::Boost. We want to limit backtraces to just the last 30
# lines becasue
class Mathcraft::BacktraceFilter
  def self.filter(bt)
    path = File.expand_path('.')
    bt.select { |line| line.start_with?(path) }.
      map { |line| line.sub(%r{\A#{path}/}, '') }.first(30)
  end
end

Minitest.backtrace_filter = Mathcraft::BacktraceFilter
