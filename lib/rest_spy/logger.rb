module RestSpy
  class Logger
    def initialize(standard_logger)
      @standard_logger = standard_logger
    end

    def log(port, request, response)
      if standard_logger
        standard_logger.info "[#{port} - #{request.method}: #{request.path} -> #{response.type} #{response.status}]"
      end
    end

    private
    attr_reader :standard_logger
    attr_accessor :requests
  end
end