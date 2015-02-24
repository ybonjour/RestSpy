require 'rest_spy/model'

module RestSpy
  module Model
    describe Double do
      it "creates Double correctly with all values" do
        headers = {header1: 'body'}
        d = Double.new('.*', 'body', 400, headers)

        expect(d.body).to be == 'body'
        expect(d.status_code).to be == 400
        expect(d.headers).to be == headers
      end

      it "creates Double with standard status code and headers" do
        d = Double.new('.*', 'body', nil, nil)

        expect(d.body).to be == 'body'
        expect(d.status_code).to be == 200
        expect(d.headers).to be == {}
      end

      it "raises an error if no body provided" do
        expect{ Double.new('.*', nil, nil, nil) }.to raise_error(ArgumentError)
      end

      it "converts the status code into an integer" do
        d = Double.new('.*', 'body', "400", nil)
        expect(d.status_code).to be 400
      end

      it "can match" do
        d = Double.new('.*', 'body', nil, nil)
        matches = d.matches('test')
        expect(matches).to be true
      end
    end
  end
end