require 'rest_spy/model/matchable'

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

      it "automatically generates an id" do
        m = Matchable.new('test')

        expect(m.id).to be =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
      end

      it "generates a unique id" do
        m1 = Matchable.new('test')
        m2 = Matchable.new('test')

        expect(m1.id).to_not be == m2.id
      end
    end
  end
end
