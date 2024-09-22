# frozen_string_literal: true

require File.expand_path 'lib/revuilt/version', __dir__

Gem::Specification.new do |spec|
  spec.name = 'revuilt'
  spec.version = Revuilt::VERSION
  spec.executables = ['revuilt']
  spec.require_paths = ['lib']
end
