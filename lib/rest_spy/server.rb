require_relative 'model'
require_relative 'application'
require 'childprocess'

at_exit do
  RestSpy::Server.stop_all_servers
end

module RestSpy
  class Server
    def initialize(port)
      @port = port
    end

    def self.stop_all_servers
      started_servers.each { |_, server| server.stop }
    end

    def start
      synchronized {
        if started_servers.include? port
          raise 'There was already a server started on this port.'
        end
        self.process = start_server_process!
        wait_until_server_running

        started_servers[port] = self
      }
    end

    def stop
      synchronized {
        return unless started_servers.include? port
        stop_server_process
        started_servers.delete(port)
      }
    end

    def post(endpoint, data)
      Faraday.new.post full_url(endpoint), data
    end

    def delete(endpoint)
      Faraday.new.delete full_url(endpoint)
    end

    private
    attr_reader :port
    attr_accessor :process

    def start_server_process!
      process = ChildProcess.build('rest-spy', '-p', port.to_s)
      process.io.inherit!
      process.start
      process
    end

    def stop_server_process
      process.stop
    end

    def wait_until(timeout=3.0, sleep=0.1, &block)
      elapsed = 0.0
      until block.call do
        sleep(sleep)
        elapsed += sleep
        raise TimeoutError if elapsed > timeout
      end
    end

    def wait_until_server_running
        wait_until { reachable? }
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

    def synchronized(&block)
      started_servers_mutex.synchronize { block.call }
    end

    def started_servers
      self.class.started_servers
    end

    def self.started_servers
      @@started_servers ||= {}
    end

    def started_servers_mutex
      @@started_servers_mutex = Mutex.new
    end
  end
end