require 'rest_spy/response_rewriter'
require 'rest_spy/model/rewrite'
require 'zlib'

module RestSpy
  describe ResponseRewriter do
    it "returns the original input if no rewrites provided" do
      rewriter = ResponseRewriter.new([])

      result = rewriter.rewrite('A body test', nil)

      expect(result).to be == 'A body test'
    end

    it "rewrites unencoded input" do
      rewrite = Model::Rewrite.new('.*', 'body', 'text')
      rewriter = ResponseRewriter.new([rewrite])

      result = rewriter.rewrite('A body test', nil)

      expect(result).to be == 'A text test'
    end

    it "applies all rewrites" do
      rewrite1 = Model::Rewrite.new('.*', 'body', 'text')
      rewrite2 = Model::Rewrite.new('.*', 'test', 'experiment')
      rewriter = ResponseRewriter.new([rewrite1, rewrite2])

      result = rewriter.rewrite('A body test', nil)

      expect(result).to be == 'A text experiment'
    end

    it "applies a rewrite to all occurences in the input" do
      rewrite1 = Model::Rewrite.new('.*', 'body', 'text')
      rewriter = ResponseRewriter.new([rewrite1])

      result = rewriter.rewrite('A body test body', nil)

      expect(result).to be == 'A text test text'
    end

    it "rewrites a gzip encoded input" do
      rewrite1 = Model::Rewrite.new('.*', 'body', 'text')

      rewriter = ResponseRewriter.new([rewrite1])

      result = rewriter.rewrite(gzip('A body test'), 'gzip')

      expect(result).to be == gzip('A text test')
    end

    it "rewrites a deflated input" do
      rewrite1 = Model::Rewrite.new('.*', 'body', 'text')

      rewriter = ResponseRewriter.new([rewrite1])

      result = rewriter.rewrite(deflate('A body test'), 'deflate')

      expect(result).to be == deflate('A text test')
    end

    def gzip(input)
      io = StringIO.new
      writer = Zlib::GzipWriter.new(io)
      writer.write(input)
      writer.close
      io.string
    end

    def deflate(input)
      Zlib::Deflate.deflate(input)
    end
  end
end