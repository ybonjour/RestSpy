RESTSpy can stub REST calls or proxy them to a real endpoint.
Currently only GET requests are supported.


Example to simulate an error code on the `/search` endpoint, while all other requests are proxied to `http://www.google.com`

```ruby
    google = RestSpy::Spy.server_on_local_port('http://www.google.com', 1234)
    google.endpoint('/search').should_return_error_code 401
    google.close
```
