require 'rest_spy/proxy_server'

module RestSpy
  describe ProxyServer do
    context "Extract HTTP Headers from environment" do

      it "should extract only fields starting with HTTP_" do
        env = { 'HTTP_Test' => 'value', 'Another_Field' => 'another value' }

        headers = ProxyServer.extract_relevant_headers(env)

        expect(headers).to be == {'Test' => 'value'}
      end

      it "should not extract the HTTP_HOST field" do
        env = { 'HTTP_Host' => 'http://www.google.com'}

        headers = ProxyServer.extract_relevant_headers(env)

        expect(headers).to be {}
      end
    end

    context "execute remote request" do
      let(:redirect_url) {'https://www.google.com'}
      let(:request_body_content) {"some content"}
      let(:request_body) {double("request_body", :read => request_body_content)}

      let(:get_request) { double('get_request',
                                 :get? => true,
                                 :post? => false,
                                 :put? => false,
                                 :delete? => false,
                                 :head? => false,
                                 :fullpath => '/stream?limit=10',) }

      let(:post_request) { double('post_request',
                                  :get? => false,
                                  :post? => true,
                                  :put? => false,
                                  :delete? => false,
                                  :head? => false,
                                  :fullpath => '/stream',
                                  :body => request_body) }

      let(:put_request) { double('put_request',
                                  :get? => false,
                                  :post? => false,
                                  :put? => true,
                                  :delete? => false,
                                  :head? => false,
                                  :fullpath => '/stream',
                                  :body => request_body) }

      let(:delete_request) { double('delete_request',
                                 :get? => false,
                                 :post? => false,
                                 :put? => false,
                                 :delete? => true,
                                 :head? => false,
                                 :fullpath => '/stream?limit=10') }

      let(:head_request) { double('head_request',
                                 :get? => false,
                                 :post? => false,
                                 :put? => false,
                                 :delete? => false,
                                 :head? => true,
                                 :fullpath => '/stream') }

      let(:headers) { {'Authorization' => 'abcd'} }
      let(:environment) { {'HTTP_Authorization' => 'abcd'} }
      let(:rewrites) { [double("rewrite")] }

      let(:http_client) {
        http_client = double('http_client')
        allow(ProxyServer).to receive(:http_client).with(rewrites).and_return(http_client)
        http_client
      }

      it "should send a correct get request" do
        expect(http_client).to receive(:get).with('https://www.google.com/stream?limit=10', headers)

        ProxyServer.execute_remote_request(get_request, redirect_url, environment, rewrites)
      end

      it "should send a correct post request" do
        expect(http_client).to receive(:post).with('https://www.google.com/stream', headers, request_body_content)

        ProxyServer.execute_remote_request(post_request, redirect_url, environment, rewrites)
      end

      it "should send a correct put request" do
        expect(http_client).to receive(:put).with('https://www.google.com/stream', headers, request_body_content)

        ProxyServer.execute_remote_request(put_request, redirect_url, environment, rewrites)
      end

      it "should send a correct delete request" do
        expect(http_client).to receive(:delete).with('https://www.google.com/stream?limit=10', headers)

        ProxyServer.execute_remote_request(delete_request, redirect_url, environment, rewrites)
      end

      it "should send a correct head request" do
        expect(http_client).to receive(:head).with('https://www.google.com/stream', headers)

        ProxyServer.execute_remote_request(head_request, redirect_url, environment, rewrites)
      end
    end
  end
end