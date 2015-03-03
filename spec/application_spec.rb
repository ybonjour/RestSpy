require File.expand_path '../spec_helper.rb', __FILE__
require 'rest_spy/application'
require 'rest_spy/proxy_server'

module RestSpy

  describe Application do

    let(:app) { RestSpy::Application }

    context "when posting a Double" do
      it "should be able to post a Double with correct params" do
        post '/doubles', {pattern: 'test', body: 'test'}

        expect(last_response).to be_ok
      end

      it "should return 400 if no pattern in params" do
        post '/doubles', {body: 'test'}
        expect(last_response.status).to be 400
      end

      it "should return 400 if no body in params" do
        post '/doubles', {pattern: 'test'}
        expect(last_response.status).to be 400
      end
    end

    context "when trying to hit a Double endpoint" do
      it "should return the double if hit" do
        post '/doubles', {pattern: '/foo', body: 'test'}

        get '/foo'

        expect(last_response).to be_ok
        expect(last_response.body).to be == 'test'
      end

      it "should return correct status_code and header" do
        headers = {'Authorization' => 'abcd'}
        post '/doubles', {pattern: '/foo_full', body: 'test', status_code: 201, headers: headers}

        get '/foo_full'

        expect(last_response.status).to be 201
        expect(last_response.body).to be == 'test'
        expect(last_response.headers).to include headers
      end

      it "should return 404 if no Double exists" do
        get '/bla'

        expect(last_response.status).to be 404
      end

      it "should return 404 if no matching Double exists" do
        post '/doubles', {pattern: '/test', body: 'test'}

        get '/bla'

        expect(last_response.status).to be 404
      end
    end

    context "when posting a Proxy" do
      it "should be able to post a proxy with correct parameters" do
        post '/proxies', {pattern: '/test', redirect_url: 'http://www.google.ch'}

        expect(last_response).to be_ok
      end

      it "should return 400 if no pattern in params" do
        post '/proxies', {redirect_url: 'http://www.google.ch'}

        expect(last_response.status).to be 400
      end

      it "should return 400 if no redirect_url in params" do
        post '/proxies', {pattern: '/test'}

        expect(last_response.status).to be 400
      end
    end

    context "when trying to hit a Proxy endpoint" do
      let(:response_headers) { {:field => 'aValue'} }
      let(:response) { double("response", :body => 'A random body', :headers => response_headers, :status => 200) }

      RSpec::Matchers.define :array_with_rewrites do |expected|
        match do |actual|
          expect(expected.size).to be == actual.size

          (0..actual.size - 1).each { |i|
            expect(expected[i].from).to be == actual[i].from
            expect(expected[i].to).to be == actual[i].to
          }
        end
      end

      it "should forward request to http_client if matching Proxy exists" do
        post '/proxies', {pattern: '/proxytest', redirect_url: 'http://www.google.com'}
        expect(ProxyServer).to receive(:execute_remote_request).with(anything, 'http://www.google.com', anything, []).and_return(response)

        get '/proxytest'

        expect(last_response.body).to be == 'A random body'
        expect(last_response.status).to be 200
        expect(last_response.headers).to include(response_headers)
      end

      it "should forward a head request" do
        post '/proxies', {pattern: '/proxytest', redirect_url: 'http://www.google.com'}
        expect(ProxyServer).to receive(:execute_remote_request).with(anything, 'http://www.google.com', anything, []).and_return(response)

        head '/proxytest'

        expect(last_response).to be_ok
      end

      it "should return 404 if no Proxy exists" do
        get '/bla'

        expect(last_response.status).to be 404
      end

      it "should return 404 if no matching Proxy exists" do
        post '/proxies', {pattern: '/test', redirect_url: 'http://www.google.com'}
        get '/bla'

        expect(last_response.status).to be 404
      end

      it "should pass on all matching rewrites to proxy" do
        rewrite1 = Model::Rewrite.new('/rewritten', 'random', 'arbitrary')
        rewrite2 = Model::Rewrite.new('/rewritten', 'body', 'text')

        post '/proxies', {pattern: '/rewritten', redirect_url: 'http://www.google.com'}
        post '/rewrites', {pattern: '/rewritten', from: rewrite1.from, to: rewrite1.to}
        post '/rewrites', {pattern: '/rewritten', from: rewrite2.from, to: rewrite2.to}

        expect(ProxyServer).to receive(:execute_remote_request)
                                .with(anything, 'http://www.google.com', anything, array_with_rewrites([rewrite1, rewrite2]))
                                .and_return(response)

        get '/rewritten'

        expect(last_response).to be_ok
      end
    end

    context "when posting a Rewrite" do
      it "should be able to post a rewrite with correct parameters" do
        post '/rewrites', {pattern: '/test', from: 'http://www.google.com', to: 'http://localhost:1234'}

        expect(last_response).to be_ok
      end

      it "should return 400 if no pattern in params" do
        post '/rewrites', {from: 'http://www.google.com', to: 'http://localhost:1234'}

        expect(last_response.status).to be 400
      end

      it "should return 400 if no from field in params" do
        post '/rewrites', {pattern: '/test', to: 'http://localhost:1234'}

        expect(last_response.status).to be 400
      end

      it "should return 400 if no to field in params" do
        post '/rewrites', {pattern: '/test', from: 'http://www.google.com'}

        expect(last_response.status).to be 400
      end
    end


    context "Presedence" do
      it "should return the Double if a Proxy and a Double match the endpoint" do
        post '/doubles', {pattern:'/foobar', body: 'test'}
        post '/proxies', {pattern:'/foobar', redirect_url: 'http://www.google.com'}

        get '/foobar'

        expect(last_response).to be_ok
        expect(last_response.body).to be == 'test'
      end
    end

    context "Remove all doubles" do
      it "should remove a double" do
        post '/doubles', {pattern:'/deleted', body: 'test'}

        delete '/doubles/all'

        get '/deleted'

        expect(last_response.status).to be 404
      end
    end
  end
end