require_relative 'matchable'

module RestSpy
  module Model
    class Double < Matchable
      def initialize(pattern, body, status_code, headers)
        super(pattern)

        @status_code = status_code
        @headers = headers
        @body = body
      end

      attr_reader :status_code, :headers, :body
    end
  end
end