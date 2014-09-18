# encoding: utf-8
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
      update_translations if valid_request?(env)
      @app.call(env)
    end

  private

    def update_translations
      WebTranslateIt.fetch_translations
      I18n.reload!
    end

    def valid_request?(env)
      !(env['PATH_INFO'] =~ /\.(js|css|jpeg|jpg|gif|png|woff)$/)
    end
  end
end
