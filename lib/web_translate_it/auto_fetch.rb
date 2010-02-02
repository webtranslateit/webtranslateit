module WebTranslateIt
  
  # Class to automatically fetch the last translations from Web Translate It
  # for every page requested.
  # This can be used as a rack middleware.
  # Implementation example:
  #
  #   # in config/environment.rb:
  #   config.middleware.use "WebTranslateIt::AutoFetch"
  #
  class AutoFetch
    def initialize(app)
      @app = app
    end
  
    def call(env)
      WebTranslateIt::fetch_translations
      status, headers, response = @app.call(env)
      [status, headers, response.body]
    end
  end
end
