# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'bundler'
Bundler.setup

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'mathcraft'

require 'minitest/boost'
require 'minitest/autorun'

class Minitest::Test
end
