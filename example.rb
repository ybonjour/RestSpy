$:.push File.expand_path("../lib", __FILE__)
require 'rest-spy'
require 'faraday'


google = RestSpy::Spy.server_on_local_port('https://www.google.de', 1234)
google.all_endpoints.should_return_error_code 400

response = Faraday.new.get('http://localhost:1234/webhp')
puts(response.status) #400

google.reset

response = Faraday.new.get('http://localhost:1234/webhp')
puts(response.status) #200