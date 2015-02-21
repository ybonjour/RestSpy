require 'singleton'

module RestSpy
  module Model
    class DoubleRegistry
        def initialize
          @doubles = []
        end

        def register(double)
          raise ArgumentError unless double
          @doubles << double
        end

        def find_double_for_endpoint(endpoint)
          @doubles.select { |d| d.matches(endpoint) }.first
        end
    end
  end
end