$:.unshift(File.expand_path('../../lib'), __FILE__)

require 'rack/test'
require 'rspec'
require 'rest_spy/application'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() RestSpy::Application end
end