require 'faraday'
require 'json'

module RestSpy
  module ProxyServer
    extend self

    def execute_remote_request(original_request, redirect_url, environment)
      headers = extract_relevant_headers(environment)
      composed_url = URI::join(redirect_url, original_request.fullpath).to_s

      if original_request.get?
        http_client.get(composed_url, headers)
      elsif original_request.post?
        http_client.post(composed_url, headers, get_body(original_request))
      elsif original_request.put?
        http_client.put(composed_url, headers, get_body(original_request))
      elsif original_request.delete?
        http_client.delete(composed_url, headers)
      else
        raise "#{original_request.request_method} requests are not supported."
      end
    end

    def extract_relevant_headers(environment)
      Hash[environment
               .select { |k, _| k.start_with?("HTTP_") && k != "HTTP_HOST"}
               .map { |k, v| [k.sub(/^HTTP_/, ''), v] }]
    end

    def get_body(request)
      #TODO: Investigate better way to extract the body (support different type of data)
      JSON.parse(request.body.read)
    end

    def http_client
      HttpClient.new
    end

    class HttpClient
      def get(url, headers)
        Faraday.new.get url do |req|
          req.headers = headers
        end
      end

      def post(url, headers, body)
        Faraday.new.post url do |req|
          req.headers = headers
          req.body = body
        end
      end

      def put(url, headers, body)
        Faraday.new.put url do |req|
          req.headers = headers
          req.body = body
        end
      end

      def delete(url, headers)
        Faraday.new.delete url do |req|
          req.headers = headers
        end
      end
    end
  end
end