require 'sinatra'
require 'rest-spy/model'
require 'rest-spy/proxy_server'

module RestSpy
  class Application < Sinatra::Base

    def set_http_client(http_client)
      raise ArgumentError unless http_client

    end

    @@DOUBLES = Model::DoubleRegistry.new
    @@PROXIES = Model::ProxyRegistry.new

    post '/doubles' do
      return 400 unless params[:pattern] && params[:body]

      pattern = /^#{params[:pattern]}$/
      d = Model::Double.new(pattern, params[:body], params[:status_code], params[:headers])
      @@DOUBLES.register(d)

      200
    end

    post '/proxies' do
      return 400 unless params[:pattern] && params[:redirect_url]

      pattern = /^#{params[:pattern]}$/
      p = Model::Proxy.new(pattern, params[:redirect_url])
      @@PROXIES.register(p)

      200
    end

    get /(.*)/ do
      capture = params[:captures].first
      double = @@DOUBLES.find_double_for_endpoint(capture)
      proxy = @@PROXIES.find_proxy_by_endpoint(capture)

      if double
        [double.status_code, double.headers, [double.body]]
      elsif proxy
        remote_response = ProxyServer.execute_remote_request(request, proxy.redirect_url, env)
        [remote_response.status, remote_response.headers, [remote_response.body]]
      else
        404
      end
    end
  end
end