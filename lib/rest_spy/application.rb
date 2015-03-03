require 'sinatra'
require 'logger'
require_relative 'model'
require_relative 'proxy_server'

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
          capture = params[:captures].first
          double = @@DOUBLES.find_for_endpoint(capture, request.port)
          proxy = @@PROXIES.find_for_endpoint(capture, request.port)
          rewrites = @@REWRITES.find_all_for_endpoint(capture, request.port)

          if double
            logger.info "[#{request.port} - #{request.request_method}: #{capture} -> Double: #{double.status_code}]"
            respond(double.status_code, double.headers, double.body)
          elsif proxy
            remote_response = ProxyServer.execute_remote_request(request, proxy.redirect_url, env, rewrites)
            logger.info "[#{request.port} - #{request.request_method}: #{capture} -> Proxy #{remote_response.status}]"
            respond(remote_response.status, remote_response.headers, remote_response.body)
          else
            404
          end
        rescue Exception => e
          logger.error(e)
          raise e
        end
      end
    end

    private
    def respond(status_code, headers, body)
      headers(headers)
      body(body)
      status(status_code)
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end