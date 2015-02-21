require 'rest-spy/model'

module RestSpy
  module Model
    describe DoubleRegistry do
      let(:double) { Double.new(/\/test/, 'body', nil, nil)}
      let(:registry) { DoubleRegistry.new }

      it "should find a registered Double" do
        registry.register(double)

        result = registry.find_double_for_endpoint('/test')

        expect(result).to be double
      end

      it "should return nil if no Double was registered" do
        result = registry.find_double_for_endpoint('/foo')

        expect(result).to be nil
      end

      it "should return nil if a non matching Double was registered" do
        registry.register(double)

        result = registry.find_double_for_endpoint('/foo')

        expect(result).to be nil
      end

      it "should return first Double if two Doubles are matching" do
        registry.register(double)
        double2 = Double.new(/\/test/, 'body2', nil, nil)
        registry.register(double2)

        result = registry.find_double_for_endpoint('/test')

        expect(result).to be double
      end
    end
  end
end