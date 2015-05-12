module RestSpy
  class SpyLogger
    def initialize(standard_logger)
      @standard_logger = standard_logger
      @requests = []
    end

    def log_request(request, response)
      if standard_logger
        standard_logger.info "[#{request.port} - #{request.method}: #{request.path} -> #{response.type} #{response.status_code}]"
      end

      requests << [request, response]
    end

    def info(text)
      return unless standard_logger
      standard_logger.info(text)
    end

    def get_requests(port=nil)
      requests.select {|e| !port || e[0].port == port}
    end

    def clear(port)
      @requests = requests.select {|e| e[0].port != port}
    end

    private
    attr_reader :standard_logger, :requests
  end
end