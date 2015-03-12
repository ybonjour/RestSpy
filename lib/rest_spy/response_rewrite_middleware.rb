require 'faraday'
require_relative 'response_rewriter'

module RestSpy
  class ResponseRewriteMiddleware < Faraday::Middleware

    def initialize(app, options=[])
      super(app)
      @rewriter = ResponseRewriter.new(options[:rewrites])
    end

    def call(request_env)
      @app.call(request_env).on_complete do |response_env|
        if response_env[:body]
          response_env[:body] = rewriter.rewrite(response_env[:body], response_env[:response_headers]['Content-Encoding'])
          response_env[:response_headers]['Content-Length'] = "#{response_env[:body].length}"
        end
      end
    end

    private
    attr_reader :rewriter
  end
end