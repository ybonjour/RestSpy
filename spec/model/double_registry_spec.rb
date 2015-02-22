require 'rest-spy/model'

module RestSpy
  module Model
    describe Registry do
      let(:element) { Double.new(/\/test/, 'body', nil, nil)}
      let(:registry) { DoubleRegistry.new }

      it "should find a registered element" do
        registry.register(element)

        result = registry.find_for_endpoint('/test')

        expect(result).to be element
      end

      it "should return nil if no Double was registered" do
        result = registry.find_for_endpoint('/foo')

        expect(result).to be nil
      end

      it "should return nil if a non matching Double was registered" do
        registry.register(element)

        result = registry.find_for_endpoint('/foo')

        expect(result).to be nil
      end

      it "should return first Double if two Doubles are matching" do
        registry.register(element)
        element2 = Double.new(/\/test/, 'body2', nil, nil)
        registry.register(element2)

        result = registry.find_double_for_endpoint('/test')

        expect(result).to be double
      end
    end
  end
end