class Locale
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    I18n.locale = req.params['locale'] || :en
    status, headers, response = @app.call(env)
    [status, headers, response]
  end
end
