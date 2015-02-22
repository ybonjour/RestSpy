require 'singleton'

module RestSpy
  module Model
    class MatchableRegistry
        def initialize
          @doubles = []
        end

        def register(double)
          raise ArgumentError unless double
          @doubles << double
        end

        def find_for_endpoint(endpoint)
          @doubles.select { |d| d.matches(endpoint) }.first
        end
    end
  end
end