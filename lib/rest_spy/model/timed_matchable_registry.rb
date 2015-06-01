require_relative 'matchable_call_countdown'

module RestSpy
  module Model
    class TimedMatchableRegistry
      INFINITE_CALLS = RestSpy::Model::MatchableCallCountDown::INFINITE_COUNT

      def initialize(matchable_registry, matchable_call_countdown)
        @registry = matchable_registry
        @countdown = matchable_call_countdown
      end

      def register(matchable, port, life_time=nil)
        life_time ||= INFINITE_CALLS
        return matchable if life_time == 0

        registry.register(matchable, port)
        countdown.start_countdown(matchable.id, port, life_time)
        matchable
      end

      def unregister(matchable_id, port)
        registry.unregister(matchable_id, port)
        countdown.expire(matchable_id, port)
      end

      def find_for_endpoint(endpoint, port)
        matchable = registry.find_for_endpoint(endpoint, port)

        if matchable
          countdown.count_down(matchable.id, port)
          if countdown.expired?(matchable.id, port)
            unregister(matchable.id, port)
          end
        end

        matchable
      end

      def reset(port)
        registry.reset(port)
      end

      private
      attr_reader :registry, :countdown
    end
  end
end
