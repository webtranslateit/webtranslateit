module WebTranslateIt
  class AutoFetch
    def initialize(app)
      @app = app
    end
  
    def call(env)
      # Update language files
      WebTranslateIt::fetch_translations
      status, headers, response = @app.call(env)
      [status, headers, response.body]
    end
  end
end
