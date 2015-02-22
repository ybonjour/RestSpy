require 'rest-spy/model/proxy'

module RestSpy
  module Model
    describe Proxy do
      it "creates Proxy correctly with all values" do
        proxy = Proxy.new('.*', 'http://www.google.com')

        expect(proxy.redirect_url).to be == 'http://www.google.com'
      end

      it "raises an error if no redirect_url is provided" do
        expect{ Proxy.new('.*', nil)}.to raise_error(ArgumentError)
      end

      it "can match" do
        p = Proxy.new('.*', 'http://www.google.com')
        matches = p.matches('test')
        expect(matches).to be true
      end
    end
  end
end