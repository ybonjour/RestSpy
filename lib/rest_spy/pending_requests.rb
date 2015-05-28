module RestSpy
  class PendingRequests
    def initialize
      @requests = {}
      @requests_lock = Mutex.new
    end

    def pending_request(request)
      synchronized {
        requests[request.port] = [] unless requests[request.port]
        requests[request.port] << request
      }
    end

    def completed_request(request)
      synchronized {
        requests[request.port].delete(request)
      }
    end

    def empty?(port)
      synchronized {
        (not requests.include? port) || requests[port].size == 0
      }
    end

    def block_until_pending_requests_completed(port, timeout_sec=15)
      #TODO: Busy waiting is bad. Check for signal possibilities
      Timeout.timeout(timeout_sec) do
        until empty?(port)
          sleep(0.1)
        end
      end
    end

    private
    attr_accessor :requests

    def synchronized(&block)
      @requests_lock.synchronize { block.call }
    end
  end
end
