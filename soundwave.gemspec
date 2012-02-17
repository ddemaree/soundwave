# -*- encoding: utf-8 -*-
require File.expand_path('../lib/soundwave/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Demaree"]
  gem.email         = ["ddemaree@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "soundwave"
  gem.require_paths = ["lib"]
  gem.version       = Soundwave::VERSION

  gem.executables = ["soundwave"]

  gem.add_runtime_dependency "activesupport", ">= 3.1.0"
  gem.add_runtime_dependency "mustache"
  gem.add_runtime_dependency "tilt"
  gem.add_runtime_dependency "fssm"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "rspec", "~> 2.8.0"
end
