module RestSpy
  module Model
    class Proxy
      def initialize(pattern, redirect_url)
        raise ArgumentError unless pattern && redirect_url

        @pattern = /^#{pattern}$/
        @redirect_url = redirect_url
      end

      attr_reader :redirect_url

      def matches(s)
        (@pattern =~ s) != nil
      end
    end
  end
end