require 'faraday'
require 'json'
require_relative 'response_rewrite_middleware'

module RestSpy
  module ProxyServer
    extend self

    def execute_remote_request(original_request, redirect_url, rewrites)
      http_client = http_client(rewrites)

      url = URI::join(redirect_url, original_request.path).to_s

      case original_request.method
        when 'GET'
          http_client.get(url, original_request.headers)
        when 'POST'
          http_client.post(url, original_request.headers, original_request.body)
        when 'PUT'
          http_client.put(url, original_request.headers, original_request.body)
        when 'DELETE'
          http_client.delete(url, original_request.headers)
        when 'HEAD'
          http_client.head(url, original_request.headers)
        else
          raise "#{original_request.method} requests are not supported."
      end
    end

    def http_client(rewrites)
      HttpClient.new(rewrites)
    end

    class HttpClient
      def initialize(rewrites=[])
        @connection = Faraday.new do |conn|
          conn.use RestSpy::ResponseRewriteMiddleware, rewrites: rewrites
          conn.adapter :net_http
        end
      end

      def head(url, headers)
        connection.get url do |req|
          req.headers = headers
        end
      end

      def get(url, headers)
        connection.get url do |req|
          req.headers = headers
        end
      end

      def post(url, headers, body)
        connection.post url do |req|
          req.headers = headers
          req.body = body
        end
      end

      def put(url, headers, body)
        connection.put url do |req|
          req.headers = headers
          req.body = body
        end
      end

      def delete(url, headers)
        connection.delete url do |req|
          req.headers = headers
        end
      end

      private
      attr_reader :connection
    end
  end
end