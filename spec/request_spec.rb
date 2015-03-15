require 'rest_spy/request'

module RestSpy
  describe Request do
    context "Extract HTTP Headers from environment" do

      it "should extract only fields starting with HTTP_" do
        env = { 'HTTP_Test' => 'value', 'Another_Field' => 'another value' }

        headers = Request.extract_relevant_headers(env)

        expect(headers).to be == {'Test' => 'value'}
      end

      it "should not extract the HTTP_HOST field" do
        env = { 'HTTP_Host' => 'http://www.google.com'}

        headers = Request.extract_relevant_headers(env)

        expect(headers).to be {}
      end

      it "should convert underscores to dashes" do
        env = {'HTTP_ACCEPT_LANGUAGE' => 'en-US'}

        headers = Request.extract_relevant_headers(env)

        expect(headers).to be == {'ACCEPT-LANGUAGE' => 'en-US'}
      end

      it "should extract content type" do
        env = {'CONTENT_TYPE' => 'application/json'}

        headers = Request.extract_relevant_headers(env)

        expect(headers).to be == {'CONTENT-TYPE' => 'application/json'}
      end
    end
  end
end