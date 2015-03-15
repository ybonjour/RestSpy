require 'rest_spy/proxy_server'
require 'rest_spy/request'

module RestSpy
  describe ProxyServer do
    context "execute remote request" do
      let(:redirect_url) {'https://www.google.com'}
      let(:body) {"some content"}
      let(:headers) { {'Authorization' => 'OAuth abcd'} }
      let(:get_request) { Request.new(1234, 'GET', '/stream?limit=10', headers) }
      let(:post_request) { Request.new(1234, 'POST', '/stream', headers, body) }
      let(:put_request) { Request.new(1234, 'PUT', '/stream', headers, body) }
      let(:delete_request) { Request.new(1234, 'DELETE', '/stream?limit=10', headers) }
      let(:head_request) { Request.new(1234, 'HEAD', '/stream', headers) }
      let(:unsupported_request) { Request.new(1234, 'LINK', '/stream', headers) }
      let(:rewrites) { [double("rewrite")] }

      let(:http_client) {
        http_client = double('http_client')
        allow(ProxyServer).to receive(:http_client).with(rewrites).and_return(http_client)
        http_client
      }

      it "should send a correct get request" do
        expect(http_client).to receive(:get).with('https://www.google.com/stream?limit=10', headers)

        ProxyServer.execute_remote_request(get_request, redirect_url, rewrites)
      end

      it "should send a correct post request" do
        expect(http_client).to receive(:post).with('https://www.google.com/stream', headers, body)

        ProxyServer.execute_remote_request(post_request, redirect_url, rewrites)
      end

      it "should send a correct put request" do
        expect(http_client).to receive(:put).with('https://www.google.com/stream', headers, body)

        ProxyServer.execute_remote_request(put_request, redirect_url, rewrites)
      end

      it "should send a correct delete request" do
        expect(http_client).to receive(:delete).with('https://www.google.com/stream?limit=10', headers)

        ProxyServer.execute_remote_request(delete_request, redirect_url, rewrites)
      end

      it "should send a correct head request" do
        expect(http_client).to receive(:head).with('https://www.google.com/stream', headers)

        ProxyServer.execute_remote_request(head_request, redirect_url, rewrites)
      end

      it "should raise an error for an unsupported method" do
        expect { ProxyServer.execute_remote_request(unsupported_request, redirect_url, rewrites) }
            .to raise_error
      end
    end
  end
end