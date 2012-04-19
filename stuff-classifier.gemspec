# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "stuff-classifier/version"

Gem::Specification.new do |s|
  s.name        = "stuff-classifier"
  s.version     = StuffClassifier::VERSION
  s.authors     = ["Alexandru Nedelcu"]
  s.email       = ["me@alexn.org"]
  s.homepage    = "https://github.com/alexandru/stuff-classifier/"
  s.summary     = %q{Simple text classifier(s) implemetation}
  s.description = %q{2 methods are provided for now - (1) naive bayes implementation + (2) tf-idf weights}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "ruby-stemmer"
  s.add_runtime_dependency "sqlite3"
  s.add_runtime_dependency "sequel"
  # Msgpack has a habbit of changing the format, so I'm setting its
  # version in stone
  s.add_runtime_dependency "msgpack", "= 0.4.6" 

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake", ">= 0.9.2"
  s.add_development_dependency "minitest", ">= 2.10"
  s.add_development_dependency "turn", ">= 0.8.3"
  s.add_development_dependency "rcov", ">= 0.9"
  # s.add_development_dependency "rdoc", ">= 3.1"
end

