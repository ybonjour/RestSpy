module RestSpy
  module Model
    class Matchable
      def initialize(pattern)
        raise ArgumentError unless pattern
        @pattern = /^#{pattern}$/
      end

      def matches(s)
        (@pattern =~ s) != nil
      end

      protected
      attr_reader :pattern
    end
  end
end