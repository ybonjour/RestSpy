require_relative 'server'
require 'json'

module RestSpy
  module Api
    class Double
      def initialize(id)
        @id = id
      end

      attr_reader :id
    end

    class CreateDouble
      def initialize(status_code, headers, body)
        @status_code = status_code
        @headers = headers
        @body = body
      end

      def perform(endpoint, life_time=nil)
        params = {:pattern => endpoint.path_pattern, :status_code => status_code, :headers=>headers, :body => body}
        params[:life_time] = life_time unless life_time.nil?
        response = endpoint.server.post('/doubles', params)
        raise "Double for #{endpoint.path_pattern} could not be created" unless response.status == 200
        Double.new(JSON.parse(response.body)['id'])
      end

      private
      attr_reader :status_code, :headers, :body
    end

    class CreateProxy
      def initialize(redirect_url)
        @redirect_url = redirect_url
      end

      def perform(endpoint, life_time=nil)
        params = {pattern: endpoint.path_pattern, redirect_url: redirect_url}
        params[:life_time] = life_time unless life_time.nil?
        endpoint.server.post '/proxies', params
      end

      private
      attr_reader :redirect_url
    end

    class SerialCommand
      def initialize(first_command)
        @commands = [first_command]
      end

      def and_then(command)
        @commands << command
        self
      end

      def perform(endpoint)
        return if @commands.empty?

        last_command = @commands.last
        rest = @commands.first(@commands.size - 1)

        last_command.perform(endpoint)

        rest.reverse.each do |command|
          command.perform(endpoint, life_time=1)
        end
      end
    end

    def return_error_code(error_code)
      CreateDouble.new(error_code, {}, '')
    end

    def proxy_to(redirect_url)
      CreateProxy.new(redirect_url)
    end

    def return_response(body = '', status_code = 200, headers = {})
      CreateDouble.new(status_code, headers, body)
    end

    def return_as_json(body)
      json_body = JSON.dump(body)
      headers = {'Content-Type' => 'application/json', 'Content-Length' => "#{json_body.length}"}
      CreateDouble.new(200, headers, json_body)
    end

    def return_as_image(path)
      headers = {'Content-Type' => "image/#{path.split(".").last}"}
      File.open(path, 'rb') { |file|
        CreateDouble.new(200, headers, file.read)
      }
    end

    def first(command)
      SerialCommand.new(command)
    end

    class Endpoint
      def initialize(server, path_pattern)
        @server = server
        @path_pattern = path_pattern
      end

      def should(command)
        command.perform(self)
      end

      def should_once(command)
        command.perform(self, life_time=1)
      end

      attr_reader :server, :path_pattern

      def create_proxy(redirect_url)
        CreateProxy.new(redirect_url).perform(self)
      end

      def create_double(status_code, headers, body)
        CreateDouble.new(status_code, headers, body).perform(self)
      end
    end

    class Spy
      def initialize(remote_url, server)
        @remote_url = remote_url
        @server = server
        @server.start
        endpoint('.*').should(proxy_to remote_url) unless remote_url.nil?
      end

      attr_reader :remote_url

      def self.from_existing_spy(rest_spy_server_url)
        Spy.new(nil, ExternalServer.new(rest_spy_server_url))
      end

      def self.from_existing_server(remote_server_url, rest_spy_server_url)
        Spy.new(remote_server_url, ExternalServer.new(rest_spy_server_url))
      end

      def self.server_on_local_port(server_url, port)
        Spy.new(server_url, LocalServer.new(port))
      end

      def rewrite(from, to)
        server.post '/rewrites', {pattern: '.*', from: from, to: to}
        self
      end

      def and_rewrite(from, to)
        rewrite(from, to)
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
end
