require File.expand_path '../spec_helper.rb', __FILE__
require 'rest-spy/application'

module RestSpy

  describe Application do

    let(:app) { RestSpy::Application }

    context "when posting a double" do
      it "should be able post a double with correct params" do
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

    context "when trying hitting a double endpoint" do
      it "should return the double if hit" do
        post '/doubles', {pattern: '/foo', body: 'test'}

        get '/foo'

        expect(last_response).to be_ok
        expect(last_response.body).to be == 'test'
      end

      it "should return 404 if no double exists" do
        get '/bla'

        expect(last_response.status).to be 404
      end

      it "should return 404 if no matching double exists" do
        post '/doubles', {pattern: '/test', body: 'test'}

        get '/bla'

        expect(last_response.status).to be 404
      end
    end
  end

end