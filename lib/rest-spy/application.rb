require 'sinatra'
require 'rest-spy/model'
require 'rest-spy/proxy_server'

module RestSpy
  class Application < Sinatra::Base

    @@DOUBLES = Model::MatchableRegistry.new
    @@PROXIES = Model::MatchableRegistry.new

    set :server, %w[thin]

    post '/doubles' do
      return 400 unless params[:pattern] && params[:body]

      $stderr.puts "[Double: #{params[:pattern]}]"

      d = Model::Double.new(params[:pattern], params[:body], params[:status_code], params[:headers])
      @@DOUBLES.register(d, request.port)

      200
    end

    delete '/doubles/all' do
      $stderr.puts "[Clear all doubles]"
      @@DOUBLES.reset(request.port)
    end

    post '/proxies' do
      return 400 unless params[:pattern] && params[:redirect_url]

      $stderr.puts "[Proxy: #{params[:pattern]} -> #{params[:redirect_url]}]"

      p = Model::Proxy.new(params[:pattern], params[:redirect_url])
      @@PROXIES.register(p, request.port)

      200
    end

    get /(.*)/ do
      capture = params[:captures].first
      double = @@DOUBLES.find_for_endpoint(capture, request.port)
      proxy = @@PROXIES.find_for_endpoint(capture, request.port)

      if double
        $stderr.puts "[Request #{capture} -> Double: #{double.status_code}]"
        respond(double.status_code, double.headers, double.body)
      elsif proxy
        remote_response = ProxyServer.execute_remote_request(request, proxy.redirect_url, env)
        $stderr.puts "[Request #{capture} -> Proxy #{remote_response.status}]"
        body = rewrite(remote_response.body)
        respond(remote_response.status, remote_response.headers, body)
      else
        404
      end
    end

    private
    def respond(status_code, headers, body)
      headers(headers)
      body(body)
      status(status_code)
    end

    def rewrite(input)
      from = 'http://api.soundcloud.dev:8989'
      to = 'http://localhost:5678'
      input.gsub(/#{from}/, "#{to}")
    end
  end
end