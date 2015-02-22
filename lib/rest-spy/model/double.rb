require_relative 'matchable'

module RestSpy
  module Model
    class Double < Matchable
      def initialize(pattern, body, status_code, headers)
        raise ArgumentError unless body
        super(pattern)

        @status_code = (status_code || 200).to_i
        @headers = headers  || {}
        @body = body
      end

      attr_reader :status_code, :headers, :body
    end
  end
end