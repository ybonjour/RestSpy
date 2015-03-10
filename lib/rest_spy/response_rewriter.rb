require 'zlib'

module RestSpy
  class ResponseRewriter
      def initialize(rewrites)
        @rewrites = rewrites
      end

      def rewrite(input, encoding)
        return input unless rewrites.size > 0

        input = decode(input, encoding)
        input = rewrites.inject(input) { |input, r| r.apply(input) }
        encode(input, encoding)
      end

      private
      attr_reader :rewrites

      def decode(input, encoding)
        case encoding
          when 'gzip'
            ungzip(input)
          when 'deflate'
            inflate(input)
          else
            input
        end
      end

      def encode(input, encoding)
        case encoding
          when 'gzip'
            gzip(input)
          when 'deflate'
            deflate(input)
          else
            input
        end
      end

      def gzip(input)
        io = StringIO.new
        writer = Zlib::GzipWriter.new(io)
        writer.write(input)
        writer.close
        io.string
      end

      def ungzip(input)
        Zlib::GzipReader.new(StringIO.new(input), :encoding => 'ASCII-8BIT').read
      end

      def inflate(input)
        Zlib::Inflate.inflate(input)
      end

      def deflate(input)
        Zlib::Deflate.deflate(input)
      end
  end
end