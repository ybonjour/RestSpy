require_relative 'server'
require 'json'

module RestSpy
  class Endpoint
    def initialize(server, path_pattern)
      @server = server
      @path_pattern = path_pattern
    end

    def should_return_error_code(error_code)
      create_double(error_code, {}, '')
    end

    def should_return(body = '', status_code = 200, headers = {})
      create_double(status_code, headers, body)
    end

    def should_return_as_json(body)
      json_body = JSON.dump(body)
      headers = {'Content-Type' => 'application/json', 'Content-Length' => "#{json_body.length}"}
      create_double(200, headers, json_body)
    end

    def should_proxy_to(redirect_url)
      create_proxy(redirect_url)
    end

    private
    attr_reader :server, :path_pattern

    def create_proxy(redirect_url)
      server.post '/proxies', {pattern: path_pattern, redirect_url: redirect_url}
    end

    def create_double(status_code, headers, body)
      server.post('/doubles', {:pattern => path_pattern, :status_code => status_code, :headers=>headers, :body => body})
    end
  end

  class Spy
    def initialize(server_url, local_port)
      @server = Server.new(local_port)
      @server.start
      endpoint('.*').should_proxy_to server_url
    end

    def self.server_on_local_port(server_url, port)
      Spy.new(server_url, port)
    end

    def and_rewrite(from, to)
      server.post '/rewrites', {pattern: '.*', from: from, to: to}
      self
    end

    def endpoint(endpoint_pattern)
      Endpoint.new(server, endpoint_pattern)
    end

    def reset
      server.delete '/doubles/all'
    end

    def all_endpoints
      Endpoint.new(server, '.*')
    end

    def get_requests
      body = server.get('/spy')
      JSON.parse(body)
    end

    def close
      server.stop
    end

    private
    attr_reader :server
  end
end