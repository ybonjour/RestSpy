require 'sinatra'
require 'logger'
require_relative 'spy_logger'
require_relative 'model'
require_relative 'proxy_server'
require_relative 'request'
require_relative 'response'
require_relative 'pending_requests'

module RestSpy
  class Application < Sinatra::Base

    @@DOUBLES = Model::MatchableRegistry.new
    @@PROXIES = Model::MatchableRegistry.new
    @@REWRITES = Model::MatchableRegistry.new
    @@PENDING_REQUESTS = PendingRequests.new

    set :server, %w[thin]

    post '/doubles' do
      return 400 unless params[:pattern] && params[:body]

      logger.info "[#{request.port} - Double: #{params[:pattern]}]"

      status_code = (params[:status_code] || 200).to_i
      headers = params[:headers] || {}
      d = Model::Double.new(params[:pattern], params[:body], status_code, headers)
      @@DOUBLES.register(d, request.port)

      200
    end

    delete '/doubles/all' do
      logger.info "[#{request.port} - Clear all doubles]"
      @@DOUBLES.reset(request.port)
    end

    post '/proxies' do
      return 400 unless params[:pattern] && params[:redirect_url]

      logger.info "[#{request.port} - Proxy: #{params[:pattPlern]} -> #{params[:redirect_url]}]"

      p = Model::Proxy.new(params[:pattern], params[:redirect_url])
      @@PROXIES.register(p, request.port)

      200
    end

    post '/rewrites' do
      return 400 unless params[:pattern] && params[:from] && params[:to]

      logger.info "[#{request.port} - Rewrite #{params[:pattern]}: #{params[:from]} -> #{params[:to]}]"

      r = Model::Rewrite.new(params[:pattern], params[:from], params[:to])
      @@REWRITES.register(r, request.port)

      200
    end

    get '/spy' do
      @@PENDING_REQUESTS.block_until_pending_requests_completed(request.port)
      requests = spy_logger.get_requests(request.port)
      body = requests.map { |e| {'request' => e[0].to_hash, 'response' => e[1].to_hash} }

      body(JSON.dump(body))
      status(200)
    end

    %w{get post put delete head}.each do |method|
      send method, /(.*)/ do
        begin
          request = extract_request
          @@PENDING_REQUESTS.pending_request(request)

          double = @@DOUBLES.find_for_endpoint(request.path, request.port)
          proxy = @@PROXIES.find_for_endpoint(request.path, request.port)
          rewrites = @@REWRITES.find_all_for_endpoint(request.path, request.port)

          if double
            response = Response.double(double)
          elsif proxy
            response = ProxyServer.execute_remote_request(request, proxy.redirect_url, rewrites)
          else
            response = Response.not_found
          end

          spy_logger.log_request(request, response)
          respond(response)
        rescue Exception => e
          response = Response.error(e)
          spy_logger.log_request(request, response) if request
          respond(response)
        ensure
          @@PENDING_REQUESTS.completed_request(request) if request
        end
      end
    end

    private
    def extract_request
      RestSpy::Request.new(
          request.port,
          request.request_method,
          request.fullpath,
          Request.extract_relevant_headers(env),
          request.body.read)
    end

    def respond(response)
      headers(response.headers)
      body(response.body)
      status(response.status_code)
    end

    def self.spy_logger
      @@spy_logger ||= SpyLogger.new(Application.logger)
    end

    def spy_logger
      Application.spy_logger
    end

    def logger
      Application.logger
    end

    def self.logger
      @@logger ||= Logger.new(STDOUT)
    end
  end
end