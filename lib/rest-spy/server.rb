require_relative 'model'
require_relative 'application'
require 'childprocess'

module RestSpy
  class Server
    @@STARTED_SERVERS = {}
    @@SERVERS_LOCK = Mutex.new

    def initialize(port)
      @port = port
      @running_lock = Mutex.new
    end

    def start
      @@SERVERS_LOCK.synchronize {
        if @@STARTED_SERVERS.include? port
          raise 'There was already a server started on this port.'
        end
        @process = start_server_process!
        wait_until_server_running

        @@STARTED_SERVERS[port] = self
      }
    end

    def stop
      @@SERVERS_LOCK.synchronize {
        return unless @@STARTED_SERVERS.include? port
        stop_server_process
        @@STARTED_SERVERS.delete(port)
      }
    end

    def post(endpoint, data)
      Faraday.new.post full_url(endpoint), data
    end

    def delete(endpoint)
      Faraday.new.delete full_url(endpoint)
    end

    at_exit do
      for _, server in @@STARTED_SERVERS
        server.stop
      end
    end

    private
    attr_reader :port, :running

    def start_server_process!
      @process = ChildProcess.build('bin/rest-spy', '-p', port.to_s)
      @process.io.inherit!
      @process.start
    end

    def stop_server_process
      @process.stop
    end

    def wait_until_server_running(timeout=3.0, sleep=0.1)
      elapsed = 0.0
      until reachable? do
        sleep(sleep)
        elapsed += sleep
        raise TimeoutError if elapsed > timeout
      end
    end

    def full_url(path)
      URI::join(base_url, path).to_s
    end

    def base_url
      "http://localhost:#{port}/"
    end

    def reachable?
      begin
        Faraday.new.get(base_url)
        true
      rescue Faraday::ConnectionFailed
        false
      end
    end
  end
end