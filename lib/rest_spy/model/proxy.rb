require_relative 'matchable'

module RestSpy
  module Model
    class Proxy < Matchable
      def initialize(pattern, redirect_url)
        raise ArgumentError unless redirect_url
        super(pattern)

        @redirect_url = redirect_url
      end

      attr_reader :redirect_url
    end
  end
end