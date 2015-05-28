require File.expand_path '../spec_helper.rb', __FILE__
require 'rest_spy/application'
require 'rest_spy/proxy_server'
require 'rest_spy/response'

module RestSpy

  describe Application do
    include RSpecMixin

    let(:response_id_pattern) { /\{"id":".*"\}/ }

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

      it "should return the double id" do
        post '/doubles', {pattern: 'foobar', body: 'test'}

        expect(last_response).to be_ok
        expect(last_response.body).to be =~ response_id_pattern
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

      it "should return the proxy id" do
        post '/proxies', {pattern: '/foo/bar', redirect_url: 'http://www.google.ch'}

        expect(last_response).to be_ok
        expect(last_response.body).to be =~ response_id_pattern
      end
    end

    context "when trying to hit a Proxy endpoint" do
      let(:response_headers) { {:field => 'aValue'} }
      let(:response) { Response.proxy(200, response_headers, 'A random body') }

      RSpec::Matchers.define :array_with_rewrites do |expected|
        match do |actual|
          expect(expected.size).to be == actual.size

          (0..actual.size - 1).each { |i|
            expect(expected[i].from).to be == actual[i].from
            expect(expected[i].to).to be == actual[i].to
          }
        end
      end

      RSpec::Matchers.define :request_with_path do |expected_path|
        match do |actual_request|
          expect(actual_request.path).to be == expected_path
        end
      end

      it "should forward request to http_client if matching Proxy exists" do
        post '/proxies', {pattern: '/proxytest', redirect_url: 'http://www.google.com'}
        expect(ProxyServer).to receive(:execute_remote_request).with(anything, 'http://www.google.com', [])
                                   .and_return(response)

        get '/proxytest'

        expect(last_response.body).to be == 'A random body'
        expect(last_response.status).to be 200
        expect(last_response.headers).to include(response_headers)
      end

      it "should forward query params" do
        post '/proxies', {pattern: '/params.*', redirect_url: 'http://www.google.com'}

        expect(ProxyServer).to receive(:execute_remote_request)
                                   .with(request_with_path('/params?value=key'), 'http://www.google.com', [])
                                   .and_return(response)

        get '/params?value=key'
      end

      it "should forward a head request" do
        post '/proxies', {pattern: '/proxytest', redirect_url: 'http://www.google.com'}
        expect(ProxyServer).to receive(:execute_remote_request)
                                   .with(anything, 'http://www.google.com', [])
                                   .and_return(response)

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
                                .with(anything, 'http://www.google.com', array_with_rewrites([rewrite1, rewrite2]))
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

      it "should return rewrite id" do
        post '/rewrites', {pattern: '/foo/bar', from: 'http://www.google.com', to: 'http://localhost:1234'}

        expect(last_response).to be_ok
        expect(last_response.body).to be =~ response_id_pattern
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

        delete '/doubles'

        get '/deleted'

        expect(last_response.status).to be 404
      end
    end

    context "Logging" do
      let!(:logger) {
        logger = double('logger')
        allow(Application).to receive(:spy_logger).and_return(logger)
        allow(logger).to receive(:info)
        logger
      }

      RSpec::Matchers.define :response_with_type do |expected_type|
        match do |actual_response|
          actual_response.type == expected_type
        end
      end

      it "should log the request and the response for a double" do
        post '/doubles', {pattern:'/logdouble', body: 'test'}

        expect(logger).to receive(:log_request).with(anything, response_with_type('double'))
        get '/logdouble'
      end

      it "should log the request and the response for a proxy" do
        post '/proxies', {pattern:'/logproxy', redirect_url: 'http://www.google.com'}
      end

      it "should log the request and the response for a 404" do
        expect(logger).to receive(:log_request).with(anything, response_with_type('not_found'))
        get '/logme'
      end

      it "should clear the log" do
        expect(logger).to receive(:clear).with(80)
        delete '/spy'
      end
    end
  end
end
