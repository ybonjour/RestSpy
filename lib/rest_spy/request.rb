module RestSpy
  class Request
    def initialize(port, method, path, headers, body=nil)
      @port = port
      @method = method.upcase
      @path = path
      @headers = headers
      @body = body
      @time = Time.now
    end

    attr_reader :port, :method, :path, :headers, :body, :time

    def to_hash
      {
          'port' => port,
          'method' => method,
          'path' => path,
          'headers' => headers,
          'body' => body,
          'time' => time
      }
    end

    def self.extract_relevant_headers(environment)
      headers = Hash[environment
                         .select { |k, _| k.start_with?("HTTP_") && k != "HTTP_HOST"}
                         .map do |k, v|
                       header_field = k.sub(/^HTTP_/, '').gsub('_', '-')
                       [header_field, v]
                     end]

      if environment['CONTENT_TYPE']
        headers['CONTENT-TYPE'] = environment['CONTENT_TYPE']
      end

      headers
    end
  end
end
