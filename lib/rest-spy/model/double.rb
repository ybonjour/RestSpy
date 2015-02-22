module RestSpy
  module Model
    class Double
      def initialize(pattern, body, status_code, headers)
        raise ArgumentError unless pattern && body

        @pattern = /^#{pattern}$/
        @status_code = (status_code || 200).to_i
        @headers = headers  || {}
        @body = body
      end

      attr_reader :status_code, :headers, :body

      def matches(s)
        (@pattern =~ s) != nil
      end
    end
  end
end