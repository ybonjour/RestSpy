$:.push File.expand_path("../lib", __FILE__)
require 'rest-spy'
require 'faraday'

facebook = RestSpy::Spy.server_on_local_port('http://www.facebook.com', 1234)
facebook.all_endpoints.should_return_error_code 500

response = Faraday.new.get('http://localhost:1234/')
puts(response.status) #500

google = RestSpy::Spy.server_on_local_port('https://www.google.de', 5678)
google.all_endpoints.should_return_error_code 400

response = Faraday.new.get('http://localhost:5678/webhp')
puts(response.status) #400

google.reset

response = Faraday.new.get('http://localhost:5678/webhp')
puts(response.status) #200