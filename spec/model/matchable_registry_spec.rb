require 'rest-spy/model'

module RestSpy
  module Model
    describe MatchableRegistry do
      let(:element) { Matchable.new('/test')}
      let(:registry) { MatchableRegistry.new }

      it "should find a registered element" do
        registry.register(element)

        result = registry.find_for_endpoint('/test')

        expect(result).to be element
      end

      it "should return nil if no element was registered" do
        result = registry.find_for_endpoint('/foo')

        expect(result).to be nil
      end

      it "should return nil if a non matching element was registered" do
        registry.register(element)

        result = registry.find_for_endpoint('/foo')

        expect(result).to be nil
      end

      it "should return first element if two elements are matching" do
        registry.register(element)
        element2 = Matchable.new('/test')
        registry.register(element2)

        result = registry.find_for_endpoint('/test')

        expect(result).to be element
      end

      it "removes all elements if reset" do
        registry.register(element)

        registry.reset

        result = registry.find_for_endpoint('/test')
        expect(result).to be nil
      end
    end
  end
end