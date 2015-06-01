require 'rest_spy/model'

module RestSpy
  module Model
    describe MatchableCallCountDown do
      let(:element_id) { 10 }
      let(:port) { 1234 }
      subject { MatchableCallCountDown.new}

      it 'should not be expired if still calls left' do
        subject.start_countdown(element_id, port, 2)
        subject.count_down(element_id, port)

        result = subject.expired?(element_id, port)

        expect(result).to be == false
      end

      it 'should expire after enough calls' do
        subject.start_countdown(element_id, port, 2)
        subject.count_down(element_id, port)
        subject.count_down(element_id, port)

        result = subject.expired?(element_id, port)

        expect(result).to be == true
      end

      it 'should not count down matchables from other ports' do
        other_port = 5678
        subject.start_countdown(element_id, port, 1)
        subject.count_down(element_id, other_port)

        result = subject.expired?(element_id, port)

        expect(result).to be == false
      end

      it 'should expire element on non existing port' do
        other_port = 5678
        subject.start_countdown(element_id, port, 1)

        result = subject.expired?(element_id, other_port)

        expect(result).to be == true
      end

      it 'should expire non existing element' do
        subject.start_countdown(element_id, port, 1)

        other_element_id = 20

        result = subject.expired?(other_element_id, port)

        expect(result).to be == true
      end

      it 'should never expire element with with infinite count' do
        subject.start_countdown(element_id, port, MatchableCallCountDown::INFINITE_COUNT)
        (1..100).to_a.each { |_| subject.count_down(element_id, port) }

        result = subject.expired?(element_id, port)

        expect(result).to be == false
      end

      it 'should correctly expire an element' do
        subject.start_countdown(element_id, port, 1)
        subject.expire(element_id, port)

        result = subject.expired?(element_id, port)
        expect(result).to be == true
      end

      it 'should not expire other elements' do
        other_element_id = 20
        subject.start_countdown(other_element_id, port, 1)

        subject.expire(element_id, port)

        result = subject.expired?(other_element_id, port)
        expect(result).to be == false
      end

      it 'should not expire elements on other ports' do
        other_port = 5678
        subject.start_countdown(element_id, other_port, 1)

        subject.expire(element_id, port)

        result = subject.expired?(element_id, other_port)
        expect(result).to be == false
      end
    end
  end
end
