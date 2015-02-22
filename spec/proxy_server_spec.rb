require 'rest-spy/proxy_server'

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
      let(:get_request) { double('get_request', :get? => true, :fullpath => '/stream?limit=10') }
      let(:post_request_body) {{a_field: 'avalue'}}
      let(:post_request) { double('post_request', :get? => false, :post? => true,
                                  :fullpath => '/stream', :body => post_request_body)
      }
      let(:headers) { {'Authorization' => 'abcd'} }
      let(:environment) { {'HTTP_Authorization' => 'abcd'} }
      let(:http_client) {
        http_client = double('http_client')
        allow(ProxyServer).to receive(:http_client).and_return(http_client)
        http_client
      }

      it "should send a correct get request" do
        expect(http_client).to receive(:get).with('https://www.google.com/stream?limit=10', headers)
        ProxyServer.execute_remote_request(get_request, redirect_url, environment)
      end

      it "should send a correct post request" do
        expect(http_client).to receive(:post).with('https://www.google.com/stream', headers, post_request_body)
        ProxyServer.execute_remote_request(post_request, redirect_url, environment)
      end
    end
  end
end