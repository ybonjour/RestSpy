require 'rest-spy/model/matchable'

module RestSpy
  module Model
    describe Matchable do
      it "matches with matching string" do
        m = Matchable.new('.*')
        matches = m.matches('test')
        expect(matches).to be true
      end

      it "does not match with non-matching string" do
        m = Matchable.new('test')
        matches = m.matches('foo')
        expect(matches).to be false
      end

      it "does not match with nil string" do
        m = Matchable.new('test')
        matches = m.matches(nil)
        expect(matches).to be false
      end

      it "does not match if the string is only partially matched" do
        m = Matchable.new('test')
        matches = m.matches('testfoo')
        expect(matches).to be false
      end

      it "raises an error if no pattern provided" do
        expect{ Matchable.new(nil) }.to raise_error(ArgumentError)
      end
    end
  end
end