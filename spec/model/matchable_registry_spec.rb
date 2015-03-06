require 'rest_spy/model'

module RestSpy
  module Model
    describe MatchableRegistry do
      let(:element) { Matchable.new('/test')}
      let(:registry) { MatchableRegistry.new }
      let(:port) { 1234 }

      it "should find a registered element" do
        registry.register(element, port)

        result = registry.find_for_endpoint('/test', port)

        expect(result).to be element
      end

      it "should return nil if no element was registered" do
        result = registry.find_for_endpoint('/foo', port)

        expect(result).to be nil
      end

      it "should return nil if a non matching element was registered" do
        registry.register(element, port)

        result = registry.find_for_endpoint('/foo', port)

        expect(result).to be nil
      end

      it "should return nil if an element was registered on a different port" do
        registry.register(element, port)

        result = registry.find_for_endpoint('/test', 4567)

        expect(result).to be nil
      end

      it "should return last added element if two elements are matching" do
        registry.register(element, port)
        element2 = Matchable.new('/test')
        registry.register(element2, port)

        result = registry.find_for_endpoint('/test', port)

        expect(result).to be element2
      end

      it "removes all elements for a port if reset" do
        registry.register(element, port)

        registry.reset(port)

        result = registry.find_for_endpoint('/test', port)
        expect(result).to be nil
      end

      it "should not reset elements from other ports" do
        registry.register(element, port)

        registry.reset(4567)

        result = registry.find_for_endpoint('/test', port)
        expect(result).to be element
      end

      context "find all elements" do
        it "returns an empty list if no elements are registered" do
          endpoints = registry.find_all_for_endpoint('/test', 1234)
          expect(endpoints).to be == []
        end

        it "does not find a non-matching endpoint" do
          registry.register(element, port)

          endpoints = registry.find_all_for_endpoint('/foo', port)

          expect(endpoints).to be == []
        end

        it "does not find a matching endpoint on another port" do
          registry.register(element, port)

          endpoints = registry.find_all_for_endpoint('/test', 4567)

          expect(endpoints).to be == []
        end

        it "finds all matching endpionts" do
          registry.register(element, port)
          element2 = Matchable.new('/.*')
          registry.register(element2, port)

          endpoints = registry.find_all_for_endpoint('/test', port)

          expect(endpoints).to be == [element, element2]
        end
      end
    end
  end
end