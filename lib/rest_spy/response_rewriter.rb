require_relative 'encoding'

module RestSpy
  class ResponseRewriter
      def initialize(rewrites)
        @rewrites = rewrites
      end

      def rewrite(input, encoding)
        return input unless rewrites.size > 0

        input = Encoding.decode(input, encoding)
        input = rewrites.inject(input) { |input, r| r.apply(input) }
        Encoding.encode(input, encoding)
      end

      private
      attr_reader :rewrites
  end
end