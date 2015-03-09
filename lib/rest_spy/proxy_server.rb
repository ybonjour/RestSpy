require 'faraday'
require 'faraday_middleware'
require 'json'
require_relative 'response_rewriter'

module RestSpy
  module ProxyServer
    extend self

    def execute_remote_request(original_request, redirect_url, environment, rewrites)
      headers = extract_relevant_headers(environment)
      composed_url = URI::join(redirect_url, original_request.fullpath).to_s

      http_client = http_client(rewrites)

      if original_request.get?
        http_client.get(composed_url, headers)
      elsif original_request.post?
        body = original_request.body.read
        puts "Body: #{body}"
        puts "Request content type: #{original_request.content_type}"
        http_client.post(composed_url, headers, body)
      elsif original_request.put?
        http_client.put(composed_url, headers, original_request.body.read)
      elsif original_request.delete?
        http_client.delete(composed_url, headers)
      elsif original_request.head?
        http_client.head(composed_url, headers)
      else
        raise "#{original_request.request_method} requests are not supported."
      end
    end

    def extract_relevant_headers(environment)
      headers = Hash[environment
               .select { |k, _| k.start_with?("HTTP_") && k != "HTTP_HOST"}
               .map do |k, v|
                  header_field = k.sub(/^HTTP_/, '').gsub('_', '-')
                  [header_field, v]
               end]

      if environment['CONTENT_TYPE']
        headers['CONTENT-TYPE'] = environment['CONTENT_TYPE']
      end

      puts "Headers: #{headers}"
      headers
    end

    def http_client(rewrites)
      HttpClient.new(rewrites)
    end

    class HttpClient
      def initialize(rewrites=[])
        @connection = Faraday.new do |conn|
          conn.use RestSpy::ResponseRewriter, rewrites: rewrites
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