module RestSpy
  module Model
    class MatchableCallCountDown
      INFINITE_COUNT = -1

      def initialize
        @counts = {}
      end

      def start_countdown(matchable_id, port, count)
        entry = Entry.new(matchable_id, port)
        counts[entry] = count
      end

      def count_down(matchable_id, port)
        entry = Entry.new(matchable_id, port)
        return unless counts.has_key? entry

        counts[entry] -= 1
      end

      def expired?(matchable_id, port)
        entry = Entry.new(matchable_id, port)
        return true unless counts.has_key? entry

        return counts[entry] == 0
      end

      def expire(matchable_id, port)
        entry = Entry.new(matchable_id, port)
        counts.delete(entry)
      end

      private
      attr_reader :counts

      class Entry < Struct.new(:matchable_id, :port)
        def initialize(matchable_id, port)
          super(matchable_id, port)
        end
      end
    end
  end
end
