require 'sinatra'
require 'logger'
require_relative 'model'
require_relative 'proxy_server'
require_relative 'request'

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

    get '/spylogs' do

    end

    %w{get post put delete head}.each do |method|
      send method, /(.*)/ do
        begin
          request = extract_request(params[:captures].first)
          puts "Request: #{request}"

          double = @@DOUBLES.find_for_endpoint(request.path, request.port)
          proxy = @@PROXIES.find_for_endpoint(request.path, request.port)
          rewrites = @@REWRITES.find_all_for_endpoint(request.path, request.port)


          if double
            logger.info "[#{request.port} - #{request.method}: #{request.path} -> Double: #{double.status_code}]"
            respond(double.status_code, double.headers, double.body)
          elsif proxy
            remote_response = ProxyServer.execute_remote_request(request, proxy.redirect_url, rewrites)
            logger.info "[#{request.port} - #{request.method}: #{request.path} -> Proxy #{remote_response.status}]"
            respond(remote_response.status, remote_response.headers, remote_response.body)
          else
            logger.info "[#{request.port} - #{request.method}: #{request.path} -> 404]"
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

    def extract_request(path)
      RestSpy::Request.new(request.port,
                           request.request_method,
                           path,
                           Request.extract_relevant_headers(env),
                           request.body.read)
    end
  end
end