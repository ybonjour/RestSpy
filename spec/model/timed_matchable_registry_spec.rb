require 'rest_spy/model'

module RestSpy
  module Model
    describe TimedMatchableRegistry do
      let(:element) { Matchable.new('/test')}
      let(:port) { 1234 }
      subject { TimedMatchableRegistry.new(MatchableRegistry.new, MatchableCallCountDown.new) }

      it 'can reset elements of port' do
        registry = double
        subject = TimedMatchableRegistry.new(registry, MatchableCallCountDown.new)
        expect(registry).to receive(:reset).with(port)

        subject.reset(port)
      end

      context 'when matchable has no lifetime' do
        it 'should register element in registry' do
          subject.register(element, port)

          result = subject.find_for_endpoint('/test', port)

          expect(result).to be element
        end

        it 'should unregister element in registry' do
          subject.register(element, port)
          subject.unregister(element.id, port)

          result = subject.find_for_endpoint('/test', port)

          expect(result).to be_nil
        end
      end

      context 'when matchable has a lifetime' do
        it 'should not find matchable after lifetime' do

          subject.register(element, port, life_time=1)

          first_result = subject.find_for_endpoint('/test', port)
          second_result = subject.find_for_endpoint('/test', port)

          expect(first_result).to be == element
          expect(second_result).to be_nil
        end

        it 'should never find a matchable with 0 lifetime' do
          subject.register(element, port, life_time=0)

          result = subject.find_for_endpoint('/test', port)

          expect(result).to be_nil
        end

        it 'should track lifetime per port' do
          port2 = 5678
          subject.register(element, port, life_time=1)
          subject.register(element, port2, life_time=1)

          first_result_port1 = subject.find_for_endpoint('/test', port)
          second_result_port1 = subject.find_for_endpoint('/test', port)
          first_result_port2 = subject.find_for_endpoint('/test', port2)
          second_result_port2 = subject.find_for_endpoint('/test', port2)

          expect(first_result_port1).to be == element
          expect(second_result_port1).to be_nil
          expect(first_result_port2).to be == element
          expect(second_result_port2).to be_nil
        end
      end
    end
  end
end
