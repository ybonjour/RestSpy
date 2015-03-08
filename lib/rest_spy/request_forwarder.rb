require 'faraday'

module RestSpy
  class RequestForwarder < Faraday::Middleware

    def initialize(app, options=[])
      super(app)
      @content_type = options[:content_type]
    end

    def call(request_env)
      puts "request env: #{request_env}"

      puts "content type: #{content_type}"

      if content_type
        request_env['CONTENT_TYPE'] = content_type
      end
      @app.call(request_env)
    end

    private
    attr_reader :content_type
  end
end