module RestSpy
  class SpyLogger
    def initialize(standard_logger)
      @standard_logger = standard_logger
    end

    def log_request(request, response)
      if standard_logger
        standard_logger.info "[#{request.port} - #{request.method}: #{request.path} -> #{response.type} #{response.status_code}]"
      end
    end

    private
    attr_reader :standard_logger
  end
end