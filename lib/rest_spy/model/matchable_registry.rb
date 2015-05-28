require 'singleton'

module RestSpy
  module Model
    class MatchableRegistry
        def initialize
          @matchables = {}
        end

        def register(double, port)
          raise ArgumentError unless double
          raise ArgumentError unless port

          @matchables[port] = [] unless @matchables[port]

          @matchables[port] << double
        end

        def unregister(double_id, port)
          return unless @matchables.include? port
          matchable = @matchables[port].find { |m| m.id == double_id}
          return if matchable.nil?
          @matchables[port].delete(matchable)
        end

        def find_for_endpoint(endpoint, port)
          find_all_for_endpoint(endpoint, port).last
        end

        def find_all_for_endpoint(endpoint, port)
          return [] unless @matchables[port]

          @matchables[port].select { |d| d.matches(endpoint) }
        end

        def reset(port)
          @matchables[port] = []
        end
    end
  end
end
