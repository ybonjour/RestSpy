require 'sinatra'
require 'rest-spy/model'

module RestSpy
  class Application < Sinatra::Base

    @@DOUBLES = Model::DoubleRegistry.new

    post '/doubles' do
      return 400 unless params[:pattern] && params[:body]

      pattern = /#{params[:pattern]}/
      d = Model::Double.new(pattern, params[:body], params[:status_code], params[:headers])
      @@DOUBLES.register(d)

      200
    end

    get /(.*)/ do
      capture = params[:captures].first
      double = @@DOUBLES.find_double_for_endpoint(capture)

      if double
        [double.status_code, double.headers, [double.body]]
      else
        404
      end
    end
  end
end