# RESTSpy [![Build Status](https://travis-ci.org/ybonjour/RestSpy.svg?branch=master)](https://travis-ci.org/ybonjour/RestSpy)
Mock REST endpoints or proxy them to real endpoints.

## Spies
A `Spy` is a local proxy server that by default redirects requests to any endpoint to another server.

In a test setup you will create a `Spy` for every REST service that your application depends on and that you want to spy on.

Once a `Spy` is created, you can start mocking certain endpoints, by providing `Doubles`. A `Double` represents a HTTP response as a triplet of a status code, headers and body.


### Examples
To get easy access to the RestSpy API you can include the ```ruby RestSpy::Api```

```ruby 
include RestSpy::Api
```

Mock `http://localhost:1234/stream` endpoint,
while requests to all other endpoints are proxied to `https://www.facebook.com`

```ruby
facebook = Spy.server_on_local_port('https://www.facebook.com', 1234)
facebook.endpoint('/stream').should(return_response('Hello world!'))
```

Endpoints can also be matched using a regular expression.
The following example shows how to mock all endpoints on `localhost:1234` that start with `stream`.
```ruby
facebook.endpoint('/stream.*').should(return_response(`Hello world!`, headers={'Token' => 'abcd'}))
```

Simulate an error code on the `http://localhost:1234/search` endpoint,
while requests to all other endpoints are proxied to `http://www.google.com`

```ruby
google = Spy.server_on_local_port('http://www.google.com', 1234)
google.endpoint('/search').should(return_error_code 401)
```
You can also define series of doubles and proxies for an endpoint:

```ruby
google.endpoint('/mail').should(
          first(return_error_code 500)
          .and_then(return_error_code 401)
          .and_then(proxy_to(facebook.remote_url)))
```




