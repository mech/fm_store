# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "fm_store/version"

Gem::Specification.new do |s|
  s.name        = "fm_store"
  s.version     = FmStore::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Swee Me Chai"]
  s.email       = ["mech@me.com"]
  s.homepage    = "https://github.com/mech/fm_store"
  s.summary     = "ActiveRecord-like access for FileMaker r/w."
  s.description = "FmStore allow ActiveRecord-like read/write access to a FileMaker database."

  s.required_rubygems_version = ">= 1.8.12"
  s.rubyforge_project         = "fm_store"

  # s.add_runtime_dependency("activemodel", ["~>3.0.3"])
  s.add_runtime_dependency("activemodel", [">=3.1.3"])
  s.add_runtime_dependency("will_paginate", ["~>3.0.2"])

  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.rdoc)
  s.require_path = 'lib'
end