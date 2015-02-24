require 'rest_spy/model'

module RestSpy
  module Model
    describe Rewrite do
      it "creates Rewrite correctly with all values" do
        r = Rewrite.new('.*', 'http://www.google.com', 'http://localhost:1234')

        expect(r.from).to be == 'http://www.google.com'
        expect(r.to).to be == 'http://localhost:1234'
      end

      it "can match" do
        r = Rewrite.new('.*', 'http://www.google.com', 'http://localhost:1234')
        matches = r.matches('test')
        expect(matches).to be true
      end

      it "replaces a string when applied" do
        text = 'This is some random string'
        rewrite = Rewrite.new('.*', 'random', 'arbitrary')

        result = rewrite.apply(text)

        expect(result).to be == 'This is some arbitrary string'
      end

      it "replaces all occurrences of a string when applied" do
        text = 'This is some random random string'
        rewrite = Rewrite.new('.*', 'random', 'arbitrary')

        result = rewrite.apply(text)

        expect(result).to be == 'This is some arbitrary arbitrary string'
      end
    end
  end
end