# frozen_string_literal: true

require_relative './test_helper'

class MathcraftTest < Minitest::Test
  test 'it has a version number' do
    refute_nil ::Mathcraft::VERSION
  end
end
