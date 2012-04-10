# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "coalmine/version"

Gem::Specification.new do |s|
  s.name        = "coalmine"
  s.version     = Coalmine::VERSION
  s.authors     = ["Brad Seefeld", "Matt Ratzloff"]
  s.email       = ["support@coalmineapp.com"]
  s.homepage    = "https://github.com/coalmine/coalmine_ruby"
  s.summary     = "Coalmine Connector Ruby implementation"
  s.description = "Send errors to the Coalmine API for logging and analytics."

  s.rubyforge_project = "coalmine"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "fakeweb"
  s.add_runtime_dependency "jsonbuilder"
end
