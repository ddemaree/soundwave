# -*- encoding: utf-8 -*-
require File.expand_path('../lib/soundwave', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Demaree"]
  gem.email         = ["ddemaree@gmail.com"]
  gem.description   = %q{Processes Mustache templates and YAML/JSON data into static web pages}
  gem.summary       = %q{A simple static website generator based on Mustache}
  gem.homepage      = "http://github.com/ddemaree/soundwave"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "soundwave"
  gem.require_paths = ["lib"]
  gem.version       = Soundwave::VERSION

  gem.executables = ["soundwave"]

  gem.add_runtime_dependency "activesupport", ">= 3.1.0"
  gem.add_runtime_dependency "mustache"
  gem.add_runtime_dependency "hike"
  gem.add_runtime_dependency "tilt"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rspec", "~> 2.8.0"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "fakefs"
  gem.add_development_dependency "watchr"
  gem.add_development_dependency "rocco"
  gem.add_development_dependency "redcarpet", "~> 1.7.0"
  gem.add_development_dependency "annotations"
  gem.add_development_dependency "rack"
  gem.add_development_dependency "sass", "~> 3.1.0"
end
