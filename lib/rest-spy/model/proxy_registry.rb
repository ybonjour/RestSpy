module RestSpy
  module Model
    class ProxyRegistry
      def initialize
        @proxies = []
      end

      def register(proxy)
        raise ArgumentError unless proxy
        @proxies << proxy
      end

      def find_proxy_by_endpoint(endpoint)
        @proxies.select { |p| p.matches(endpoint) }.first
      end
    end
  end
end