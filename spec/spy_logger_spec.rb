require 'rest_spy/spy_logger'
require 'rest_spy/request'
require 'rest_spy/response'

module RestSpy
  describe SpyLogger do
    let(:standard_logger) { double("standard_logger") }
    let(:logger) {
      allow(standard_logger).to receive("info")
      SpyLogger.new(standard_logger)
    }

    let(:request) { Request.new(1234, 'GET', '/stream', {}, nil) }
    let(:response) { Response.new('proxy', 200, {}, nil) }

    it "logs to standard logger" do
      expect(standard_logger).to receive(:info).with('[1234 - GET: /stream -> proxy 200]')

      logger.log_request(request, response)
    end

    it "returns an empty list if no requests have been logged" do
      requests = logger.get_requests
      expect(requests).to be == []
    end

    it "finds the request for a given port" do
      logger.log_request(request, response)

      requests = logger.get_requests(1234)

      expect(requests).to be == [[request, response]]
    end

    it "finds all requests if no port provided" do
      logger.log_request(request, response)

      requests = logger.get_requests

      expect(requests).to be == [[request, response]]
    end

    it "does not find requests of another port" do
      logger.log_request(request, response)

      requests = logger.get_requests(5678)

      expect(requests).to be == []
    end

    it "finds mulitple requests for same port" do
      request2 = Request.new(1234, 'GET', '/stream', {}, nil)
      response2 = Response.new('double', 500, {}, nil)
      logger.log_request(request, response)
      logger.log_request(request2, response2)

      requests = logger.get_requests(1234)

      expect(requests).to be == [[request, response], [request2, response2]]
    end

    it "finds mulitple requests for different ports" do
      request2 = Request.new(5678, 'GET', '/stream', {}, nil)
      response2 = Response.new('double', 500, {}, nil)
      logger.log_request(request, response)
      logger.log_request(request2, response2)

      requests = logger.get_requests

      expect(requests).to be == [[request, response], [request2, response2]]
    end

    it "clears requests for a port" do
      logger.log_request(request, response)

      logger.clear(1234)

      expect(logger.get_requests).to be == []
    end

    it "does not clear requests for another port" do
      logger.log_request(request, response)

      logger.clear(5678)

      expect(logger.get_requests).to be == [[request, response]]
    end
  end
end