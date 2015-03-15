require 'sinatra'
require 'logger'
require_relative 'spy_logger'
require_relative 'model'
require_relative 'proxy_server'
require_relative 'request'
require_relative 'response'

module RestSpy
  class Application < Sinatra::Base

    @@DOUBLES = Model::MatchableRegistry.new
    @@PROXIES = Model::MatchableRegistry.new
    @@REWRITES = Model::MatchableRegistry.new

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

      logger.info "[#{request.port} - Proxy: #{params[:pattern]} -> #{params[:redirect_url]}]"

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

    %w{get post put delete head}.each do |method|
      send method, /(.*)/ do
        begin
          request = extract_request(params[:captures].first)

          double = @@DOUBLES.find_for_endpoint(request.path, request.port)
          proxy = @@PROXIES.find_for_endpoint(request.path, request.port)
          rewrites = @@REWRITES.find_all_for_endpoint(request.path, request.port)

          if double
            response = Response.double(double)
            spy_logger.log_request(request, response)
            logger.info "[#{request.port} - #{request.method}: #{request.path} -> Double: #{double.status_code}]"
            respond(response)
          elsif proxy
            response = ProxyServer.execute_remote_request(request, proxy.redirect_url, rewrites)
            spy_logger.log_request(request, response)
            logger.info "[#{request.port} - #{request.method}: #{request.path} -> Proxy #{response.status_code}]"
            respond(response)
          else
            response = Response.not_found
            spy_logger.log_request(request, response)
            logger.info "[#{request.port} - #{request.method}: #{request.path} -> 404]"
            respond(response)
          end
        rescue Exception => e
          logger.error(e)
          raise e
        end
      end
    end

    private
    def extract_request(path)
      RestSpy::Request.new(
          request.port,
          request.request_method,
          path,
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