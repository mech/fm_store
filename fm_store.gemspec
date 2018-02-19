# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fm_store/version"

Gem::Specification.new do |spec|
  spec.name          = 'fm_store'
  spec.version       = FmStore::VERSION
  spec.authors       = ['mech']
  spec.email         = ['mech@me.com']
  spec.summary       = 'ActiveRecord-like access for FileMaker r/w.'
  spec.description   = 'FmStore allow ActiveRecord-like read/write access to a FileMaker database.'
  spec.homepage      = 'https://github.com/mech/fm_store'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activemodel'
  spec.add_runtime_dependency 'lardawge-rfm'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.0'
end
