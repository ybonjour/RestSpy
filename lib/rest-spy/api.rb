require_relative 'server'

module RestSpy
  class Endpoint
    def initialize(server, path_pattern)
      @server = server
      @path_pattern = path_pattern
    end

    def should_return_error_code(error_code)
      server.post('/doubles', {:pattern => path_pattern, :status_code => error_code, :body => ''})
    end

    private
    attr_reader :server, :path_pattern
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