require_relative 'model'
require_relative 'application'
require 'childprocess'

at_exit do
  RestSpy::Server.stop_all_servers
end

module RestSpy
  class ServerRegistry
    include Singleton

    def initialize
      @servers = {}
      @mutex = Mutex.new
    end

    attr_reader :mutex

    def register(server)
      raise 'server for that port is already registered' if servers.include? server.port

      servers[server.port] = server
    end

    def unregister(server)
      return false unless servers.include? server.port
      servers.remove(server.port)
      true
    end

    def each
      servers.each
    end

    private
    attr_reader :servers
  end

  class Server
    def initialize(port)
      @port = port
    end

    attr_reader :port

    def self.stop_all_servers
      ServerRegistry.instance.each { |server| server.stop }
    end

    def start
      synchronized {
        ServerRegistry.instance.register(self)
        self.process = start_server_process!
        wait_until_server_running
      }
    end

    def stop
      synchronized {
        return unless ServerRegistry.instance.unregister(self)
        stop_server_process
      }
    end

    def post(endpoint, data)
      Faraday.new.post full_url(endpoint), data
    end

    def delete(endpoint)
      Faraday.new.delete full_url(endpoint)
    end

    def get(endpoint)
      response = Faraday.new.get full_url(endpoint)
      raise "Status Code (#{response.status}) is not 200" unless response.status == 200
      response.body
    end

    private
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

    def started_servers_mutex
      ServerRegistry.instance.mutex
    end
  end
end