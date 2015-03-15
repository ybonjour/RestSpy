module RestSpy
  class Response
    def initialize(type, status_code, headers, body)
      @type = type
      @status_code = status_code
      @headers = headers
      @body = body
    end

    attr_reader :type, :status_code, :headers, :body

    def to_hash
      {
          'type' => type,
          'status_code' => status_code,
          'headers' => headers,
          'body' => response_body
      }
    end
  end
end