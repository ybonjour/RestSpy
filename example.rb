require 'bundler/setup'

require 'rest_spy'
require 'faraday'

facebook = RestSpy::Spy.server_on_local_port('http://www.facebook.com', 1234)
facebook.endpoint('/stream.*').should_return('Hello world!')

response = Faraday.new.get('http://localhost:1234/stream?limit=100')
puts(response.body) #Hello world!

google = RestSpy::Spy.server_on_local_port('https://www.google.de', 5678).and_rewrite('Google', 'Facebook')
google.all_endpoints.should_return_error_code 400

response = Faraday.new.get('http://localhost:5678/webhp')
puts(response.status) #400

google.reset

response = Faraday.new.get('http://localhost:5678/webhp')
puts(response.status) #200

google.endpoint('/json').should_return_as_json({"author" => {"name" => "Yves"}})

response = Faraday.new.get('http://localhost:5678/json')
puts(response.body) # {"author":{"name":"Yves"}}

puts(facebook.get_requests) #requests

facebook.clear_requests

puts(facebook.get_requests == []) #true

google.endpoint('/cat').should_return_as_jpeg('test_image.jpg')
response = Faraday.new.get('http://localhost:5678/cat')
puts(response.status) #200
puts(response.headers["content-type"]) #image/jpeg