# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cdn_sumo_sprockets_rails2/rails2/version"

Gem::Specification.new do |s|
  s.name        = "cdn_sumo_sprockets_rails2"
  s.version     = CdnSumoSprockets::Rails2::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Richard Schneeman"]
  s.email       = ["richard.schneeman@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Provides asset pipeline and CDN Sumo functionality to Rails 2.3}
  s.description = %q{The gem allows Rails 2.3 apps to use the
                     same asset pipeline functionality introduced in Rails 3.1.
                     It does this by integrating the Sprockets gem into a Rails
                     2.3 app, and automatically applying configuration for CDN Sumo }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency("sprockets", '~> 2.8.2')
end
