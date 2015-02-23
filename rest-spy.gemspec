# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'rest-spy/version'

Gem::Specification.new do |s|
  s.name                  = "rest-spy"
  s.version               = RestSpy::VERSION
  s.platform              = Gem::Platform::RUBY
  s.authors               = ['Yves Bonjour']
  s.email                 = ['yves.bonjour@gmail.com']
  s.homepage              = %q{https://github.com/ybonjour/RestSpy}
  s.summary               = %q{Mocks REST endpoints or proxy them to real endpoints}
  s.description           = %q{RESTSpy starts a local web server to which your system under test connects. You can then either configure mocks for endpoints or forward them to the real web service.}
  s.license               = 'Apache-2.0'

  s.required_ruby_version = '>= 1.8.7'

  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables           = ['rest-spy']
  s.require_paths         = ['lib']

  s.add_dependency 'sinatra'
  s.add_dependency 'faraday'
  s.add_dependency 'childprocess'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack-test'
end
