require 'rest-spy/model/proxy'

module RestSpy
  module Model
    describe Proxy do
      it "creates Proxy correctly with all values" do
        proxy = Proxy.new(/.*/, 'http://www.google.com')

        expect(proxy.redirect_url).to be == 'http://www.google.com'
      end

      it "raises an error if no pattern is provided" do
        expect{ Proxy.new(nil, 'http://www.google.com')}.to raise_error(ArgumentError)
      end

      it "raises an error if no redirect_url is provided" do
        expect{ Proxy.new(/.*/, nil)}.to raise_error(ArgumentError)
      end

      it "matches with matching string" do
        p = Proxy.new(/test/, 'http://www.google.com')
        matches = p.matches('test')
        expect(matches).to be true
      end

      it "does not match with non-matching string" do
        p = Proxy.new(/test/, 'http://www.google.com')
        matches = p.matches('foo')
        expect(matches).to be false
      end

      it "does not match with nil string" do
        p = Proxy.new(/test/, 'http://www.google.com')
        matches = p.matches(nil)
        expect(matches).to be false
      end
    end
  end
end