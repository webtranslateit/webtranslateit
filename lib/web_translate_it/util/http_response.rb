# frozen_string_literal: true

module WebTranslateIt

  module HttpResponse

    STATUS_LABELS = {
      200 => 'OK',
      201 => 'Created',
      202 => 'Accepted',
      304 => 'Not Modified'
    }.freeze

    def self.handle_response(response)
      raise_on_error!(response)
      response.body
    end

    def self.status_label(response)
      raise_on_error!(response)
      label = STATUS_LABELS[response.code.to_i]
      StringUtil.success(label || 'OK')
    rescue RuntimeError => e
      StringUtil.failure(e.message)
    end

    def self.add_fields(request)
      request.add_field('User-Agent', "wti v#{Util.version}")
      request.add_field('Content-Type', 'application/json')
    end

    def self.raise_on_error!(response)
      code = response.code.to_i
      if code >= 400 && code < 500
        raise "Error: #{MultiJson.load(response.body)['error']}"
      elsif code == 500
        raise 'Error: Server temporarily unavailable (Error 500).'
      elsif code == 503
        raise 'Error: Locked (another import in progress)'
      end
    end
    private_class_method :raise_on_error!

  end

end
