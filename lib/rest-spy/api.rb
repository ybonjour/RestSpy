require_relative 'server'

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

    private
    attr_reader :server, :path_pattern

    def create_double(status_code, headers, body)
      server.post('/doubles', {:pattern => path_pattern, :status_code => status_code, :headers=>headers, :body => body})
    end
  end

  class Spy
    def initialize(server_url, local_port)
      @server = Server.new(local_port)
      @server.start
      @server.post '/proxies', {pattern: '.*', redirect_url: server_url}
    end

    def self.server_on_local_port(server_url, port)
      Spy.new(server_url, port)
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

    def close
      server.stop
    end

    private
    attr_reader :server
  end
end