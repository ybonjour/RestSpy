require_relative 'matchable'

module RestSpy
  module Model
    class Rewrite < Matchable
      def initialize(pattern, from, to)
        super(pattern)
        @from = from
        @to = to
      end

      def apply(text)
        text.gsub(from, to)
      end

      attr_reader :from, :to
    end
  end
end