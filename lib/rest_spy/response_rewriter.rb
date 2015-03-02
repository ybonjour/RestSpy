require 'faraday'

module RestSpy
  class ResponseRewriter < Faraday::Middleware

    def initialize(app, options=[])
      super(app)
      @rewrites = options[:rewrites] || []
    end

    def call(request_env)
      @app.call(request_env).on_complete do |response_env|
        if response_env[:body]
          response_env[:body] = apply_rewrites(response_env[:body])
        end
      end
    end

    private
    attr_reader :rewrites

    def apply_rewrites(body)
      rewrites.inject(body) { |body, r| r.apply(body) }
    end
  end
end