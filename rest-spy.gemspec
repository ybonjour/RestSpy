# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'rest-spy/version'

Gem::Specification.new do |s|
  s.name                  = "rest-spy"
  s.version               = RestSpy::VERSION
  s.platform              = Gem::Platform::RUBY
  s.authors               = ['Yves Bonjour']
  s.email                 = ['yves.bonjour@gmail.com']
  #s.homepage             = %q{TODO: add homepage}	
  s.summary               = %q{Stub REST endpoints or forwards them to the real endpoint.}
  #s.description          = %q{TODO: Write a gem description}

  s.required_ruby_version = '>= 1.8.7'

  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths         = ['lib']

  s.add_dependency 'sinatra', '~> 1.4.0'
  s.add_dependency 'faraday'

  s.add_development_dependency 'rspec', '~> 3.2.0'
  s.add_development_dependency 'rack-test'
end
