require 'rest_spy/spy_logger'
require 'rest_spy/request'
require 'rest_spy/response'

module RestSpy
  describe SpyLogger do
    let(:standard_logger) { double("standard_logger") }
    let(:logger) { SpyLogger.new(standard_logger) }

    it "logs to standard logger" do
      request = Request.new(1234, 'GET', '/stream', {}, nil)
      response = Response.new('proxy', 200, {}, nil)

      expect(standard_logger).to receive(:info).with('[1234 - GET: /stream -> proxy 200]')

      logger.log_request(request, response)
    end
  end
end