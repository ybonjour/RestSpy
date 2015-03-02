require 'singleton'

module RestSpy
  module Model
    class MatchableRegistry
        def initialize
          @doubles = {}
        end

        def register(double, port)
          raise ArgumentError unless double
          raise ArgumentError unless port

          @doubles[port] = [] unless @doubles[port]

          @doubles[port] << double
        end

        def find_for_endpoint(endpoint, port)
          find_all_for_endpoint(endpoint, port).first
        end

        def find_all_for_endpoint(endpoint, port)
          return [] unless @doubles[port]

          @doubles[port].select { |d| d.matches(endpoint) }
        end

        def reset(port)
          @doubles[port] = []
        end
    end
  end
end