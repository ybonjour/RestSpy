# RESTSpy
Mock REST endpoints or proxy them to real endpoints.

## Spies
A `Spy` is a local proxy server that by default redirects requests to any endpoint to another server.

In a test setup you will create a `Spy` for every dependent REST serverice you want to spy on.

Once a `Spy` is created, you can start mocking certain endpoints, by providing `Doubles`. A `Double` represents a HTTP response as a triplet of a status code, headers and body.


### Examples
Mock `http://localhost:1234/stream` endpoint,
while requests to all other endpoints are proxied to `https://www.facebook.com`

```ruby
facebook = RestSpy::Spy.server_on_local_port('https://www.facebook.com', 1234)
facebook.endpoint('/stream').should_return('Hello world!')
```

Endpoints can also be matched using a regular expression.
The following example shows how to mock all endpoints on `localhost:1234` that start with `stream`.
```ruby
facebook.endpoint('/stream.*').should_return(`Hello world!`, headers={'Token' => 'abcd'})
```

Simulate an error code on the `http://localhost:1234/search` endpoint,
while requests to all other endpoints are proxied to `http://www.google.com`

```ruby
google = RestSpy::Spy.server_on_local_port('http://www.google.com', 1234)
google.endpoint('/search').should_return_error_code 401
```





