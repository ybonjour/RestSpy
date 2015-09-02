require 'zlib'

module RestSpy
  module Encoding
    extend self

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
      Zlib::GzipReader.new(StringIO.new(input), :encoding => 'UTF-8').read
    end

    def inflate(input)
      Zlib::Inflate.inflate(input)
    end

    def deflate(input)
      Zlib::Deflate.deflate(input)
    end
  end
end
