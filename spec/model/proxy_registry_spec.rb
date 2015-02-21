require 'rest-spy/model'

module RestSpy
  module Model
    describe ProxyRegistry do
      let(:proxy) { Proxy.new(/\/test/, 'http://www.google.com') }
      let(:registry) { ProxyRegistry.new }

      it "should find a registered Proxy" do
        registry.register(proxy)

        result = registry.find_proxy_for_endpoint('/test')

        expect(result).to be proxy
      end

      it "should return nil if no Proxy was registered" do
        result = registry.find_proxy_for_endpoint('/foo')

        expect(result).to be nil
      end

      it "should return nil if a non matching Proxy was registered" do
        registry.register(proxy)

        result = registry.find_proxy_for_endpoint('/foo')

        expect(result).to be nil
      end

      it "should return first Proxy if two Proxies are matching" do
        registry.register(proxy)
        proxy2 = Proxy.new(/\/test/, 'http://www.facebook.com')
        registry.register(proxy2)

        result = registry.find_proxy_for_endpoint('/test')

        expect(result).to be proxy
      end
    end
  end
end