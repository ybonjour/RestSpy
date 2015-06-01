require 'bundler/setup'

require 'rest_spy'
require 'faraday'

include RestSpy::Api


# Create a spy and mock all endpoints starting with stream
facebook = Spy.server_on_local_port('http://www.facebook.com', 1234)
facebook.endpoint('/stream.*').should(return_response('Hello world!'))
response = Faraday.new.get('http://localhost:1234/stream?limit=100')
puts(response.body) #Hello world!

# Mock an endpoint with a specific status code
google = Spy.server_on_local_port('https://www.google.de', 5678).and_rewrite('Google', 'Facebook')
google.all_endpoints.should(return_error_code 400)
response = Faraday.new.get('http://localhost:5678/webhp')
puts(response.status) #400

# Reset the spy so that requests to all endpoints are proxied again
google.reset
response = Faraday.new.get('http://localhost:5678/webhp')
puts(response.status) #200

# Mock an endpoint with a json body
google.endpoint('/json').should(return_as_json({"author" => {"name" => "Yves"}}))
response = Faraday.new.get('http://localhost:5678/json')
puts(response.body) # {"author":{"name":"Yves"}}

# Retrieve all requests that have been sent to a spy
puts(facebook.get_requests) #requests

# Clear the log of all requests for a spy
facebook.clear_requests
puts(facebook.get_requests == []) #true

# Mock an endpoint with a JPEg
google.endpoint('/cat').should(return_as_jpeg('test_image.jpg'))
response = Faraday.new.get('http://localhost:5678/cat')
puts(response.status) #200
puts(response.headers["content-type"]) #image/jpeg

# Remove a specific double from a spy
double = google.endpoint('/mail').should(return_error_code 500)
google.remove_double(double)
response = Faraday.new.get('http://localhost:5678/mail')
puts(response.status) #301

# A double that only responds to one request
google.endpoint('/mail').should_once(return_error_code 500)
response = Faraday.new.get('http://localhost:5678/mail')
puts(response.status) #500
response = Faraday.new.get('http://localhost:5678/mail')
puts(response.status) #301

# A chain of doubles
facebook.endpoint('/mail')
    .should(first(return_error_code 500).and_then(return_error_code 401).and_then(proxy_to(google.remote_url)))

response = Faraday.new.get('http://localhost:1234/mail')
puts(response.status) #500

response = Faraday.new.get('http://localhost:1234/mail')
puts(response.status) #401

response = Faraday.new.get('http://localhost:1234/mail')
puts(response.status) #301



