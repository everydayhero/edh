# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'edh/version'

Gem::Specification.new do |gem|
  gem.name        = "edh"
  gem.summary     = "A lightweight, flexible library for EDH Passport"
  gem.description = "A lightweight, flexible library for EDH Passport"
  gem.homepage    = "http://github.com/everydayhero/edh"
  gem.version     = EDH::VERSION

  gem.authors     = ["Alex Koppel", "Joel Richards"]
  gem.email       = "joelr@everydayhero.com.au"

  gem.require_paths  = ["lib"]
  gem.files          = `git ls-files`.split("\n")
  gem.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables    = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  gem.extra_rdoc_files = ["readme.md", "changelog.md"]
  gem.rdoc_options     = ["--line-numbers", "--inline-source", "--title", "EDH"]

  gem.add_runtime_dependency("multi_json")
  gem.add_runtime_dependency("faraday")
  gem.add_runtime_dependency("addressable")
  gem.add_development_dependency("rspec")
  gem.add_development_dependency("rake")
end
