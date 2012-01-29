# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fog_tracker/version"

Gem::Specification.new do |s|
  s.name        = "fog_tracker"
  s.version     = FogTracker::VERSION
  s.authors     = ["Benton Roberts"]
  s.email       = ["benton@bentonroberts.com"]
  s.homepage    = "http://github.com/benton/fog_tracker"
  s.summary     = %q{Tracks the state of cloud computing resources across }+
                  %q{multiple accounts with multiple service providers}
  s.description = %q{This gem peridically polls mutiple cloud computing }+
                  %q{services using the fog gem, asynchronously updating the }+
                  %q{state of the resulting collections of Fog Resources.}

  s.rubyforge_project = "fog_tracker"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Runtime dependencies
  s.add_dependency "fog"

  # Development / Test dependencies
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "yard"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "ruby_gntp"
end
