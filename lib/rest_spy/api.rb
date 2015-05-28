require_relative 'server'
require 'json'

module RestSpy
  class Double
    def initialize(id)
      @id = id
    end

    attr_reader :id
  end

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

    def should_return_as_jpeg(path)
      File.open(path, 'rb') {|file|
        headers = {'Content-Type' => 'image/jpeg'}
        create_double(200, headers, file.read)
      }
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
      response = server.post('/doubles', {:pattern => path_pattern, :status_code => status_code, :headers=>headers, :body => body})
      raise "Double for #{path_pattern} could not be created" unless response.status == 200
      Double.new(JSON.parse(response.body)['id'])
    end
  end

  class Spy
    def initialize(server_url, server)
      @server = server
      @server.start
      endpoint('.*').should_proxy_to server_url
    end

    def self.from_existing_server(remote_server_url, rest_spy_server_url)
      Spy.new(remote_server_url, ExternalServer.new(rest_spy_server_url))
    end

    def self.server_on_local_port(server_url, port)
      Spy.new(server_url, LocalServer.new(port))
    end

    def and_rewrite(from, to)
      server.post '/rewrites', {pattern: '.*', from: from, to: to}
      self
    end

    def endpoint(endpoint_pattern)
      Endpoint.new(server, endpoint_pattern)
    end

    def remove_double(double)
      server.delete "/doubles/#{double.id}"
    end

    def reset
      server.delete '/doubles'
    end

    def all_endpoints
      Endpoint.new(server, '.*')
    end

    def get_requests
      body = server.get('/spy')
      JSON.parse(body)
    end

    def clear_requests
      server.delete('/spy')
    end

    def close
      server.stop
    end

    private
    attr_reader :server
  end
end
