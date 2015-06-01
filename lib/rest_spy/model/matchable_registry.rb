require 'singleton'

module RestSpy
  module Model
    class MatchableRegistry
      def initialize
        @matchables = {}
      end

      def register(matchable, port)
        raise ArgumentError unless matchable
        raise ArgumentError unless port

        matchables[port] = [] unless matchables[port]

        matchables[port] << matchable
      end

      def unregister(matchable_id, port)
        return unless matchables.include? port
        matchable = matchables[port].find { |m| m.id == matchable_id}
        return if matchable.nil?
        matchables[port].delete(matchable)
      end

      def unregister_if(port, predicate)
        return unless matchables.include? port
        matchables[port].select { |m| predicate.call(m) }.each { |m|
            unregister(m.id, port)
        }
      end

      def find_for_endpoint(endpoint, port)
        find_all_for_endpoint(endpoint, port).last
      end

      def find_all_for_endpoint(endpoint, port)
        return [] unless matchables[port]

        matchables[port].select { |d| d.matches(endpoint) }
      end

      def reset(port)
        matchables[port] = []
      end

      private
      attr_reader :matchables
    end
  end
end
