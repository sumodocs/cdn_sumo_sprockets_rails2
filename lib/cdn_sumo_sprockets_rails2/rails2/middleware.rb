
module Sprockets
  module Rails2
    class Middleware
      PREFIX = %r{/assets}

      def initialize(app)
        @app = app
      end

      def call(env)
        if env['PATH_INFO'] =~ PREFIX
          env['PATH_INFO']  = env['PATH_INFO'].sub(PREFIX, "")
          Rails.asset_pipeline.call(env)
        else
          @app.call(env)
        end
      end
    end
  end
end
