require 'rest-spy/model'

module RestSpy
  module Model
    describe Double do
      it "creates Double correctly with all values" do
        headers = {header1: 'body'}
        d = Double.new(/.*/, 'body', 400, headers)

        expect(d.body).to be == 'body'
        expect(d.status_code).to be == 400
        expect(d.headers).to be == headers
      end

      it "creates Double with standard status code and headers" do
        d = Double.new(/.*/, 'body', nil, nil)

        expect(d.body).to be == 'body'
        expect(d.status_code).to be == 200
        expect(d.headers).to be == {}
      end

      it "raises an error if no pattern provided" do
        expect{ Double.new(nil, 'body', nil, nil) }.to raise_error(ArgumentError)
      end

      it "raises an error if no body provided" do
        expect{ Double.new(/.*/, nil, nil, nil) }.to raise_error(ArgumentError)
      end

      it "matches with matching string" do
        d = Double.new(/.*/, 'body', nil, nil)
        matches = d.matches('test')
        expect(matches).to be true
      end

      it "does not match with non-matching string" do
        d = Double.new(/test/, 'body', nil, nil)
        matches = d.matches('foo')
        expect(matches).to be false
      end

      it "does not match with nil string" do
        d = Double.new(/test/, 'body', nil, nil)
        matches = d.matches(nil)
        expect(matches).to be false
      end
    end
  end
end