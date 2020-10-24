# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mathcraft/version'

Gem::Specification.new do |spec|
  spec.name          = 'mathcraft'
  spec.version       = Mathcraft::VERSION
  spec.authors       = ['Eric K Idema']
  spec.email         = ['eki@vying.org']

  spec.summary       = 'A mathtastic computer algebra system.'
  spec.description   = 'A mathemagical computer algebra system.'
  spec.homepage      = 'https://github.com/eki/mathcraft'

  spec.files         = Dir['lib/**/*', 'bin/*', 'README.md']
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.6'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-boost'
  spec.add_development_dependency 'simplecov'
end
