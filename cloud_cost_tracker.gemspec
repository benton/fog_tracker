# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cloud_cost_tracker/version"

Gem::Specification.new do |s|
  s.name        = "cloud_cost_tracker"
  s.version     = CloudCostTracker::VERSION
  s.authors     = ["Benton Roberts"]
  s.email       = ["benton@bentonroberts.com"]
  s.homepage    = "http://github.com/benton/cloud_cost_tracker"
  s.summary     = %q{Generates per-resource, ActiveRecord-compatible }+
                  %q{BillingRecords for Cloud services}
  s.description = %q{This gem peridically polls cloud computing services }+
                  %q{using the fog gem, and generates ActiveRecord rows }+
                  %q{representing BillingRecords for each discovered resource.}

  s.rubyforge_project = "cloud_cost_tracker"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Runtime dependencies
  s.add_dependency "fog"
  s.add_dependency "activerecord"

  # Development / Test dependencies
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "sqlite3"
end
