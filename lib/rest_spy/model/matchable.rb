require 'securerandom'
module RestSpy
  module Model
    class Matchable
      def initialize(pattern)
        @pattern = /^#{pattern}$/
        @id = SecureRandom.uuid
      end

      attr_reader :id

      def matches(s)
        (@pattern =~ s) != nil
      end

      protected
      attr_reader :pattern
    end
  end
end
