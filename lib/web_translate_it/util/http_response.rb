# frozen_string_literal: true

module WebTranslateIt

  class RateLimitError < StandardError

    attr_reader :retry_after

    def initialize(retry_after: nil)
      @retry_after = retry_after
      super("Rate limited#{", retry after #{retry_after}s" if retry_after}")
    end

  end

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
      raise_on_rate_limit!(response) if code == 429
      raise "Error: #{error_message(response)}" if code >= 400 && code < 500
      raise 'Error: Server temporarily unavailable (Error 500).' if code == 500
      raise 'Error: Locked (another import in progress)' if code == 503
    end

    def self.raise_on_rate_limit!(response)
      retry_after = response['Retry-After']&.to_i
      raise RateLimitError.new(retry_after: retry_after)
    end

    def self.error_message(response)
      MultiJson.load(response.body)['error']
    rescue StandardError
      response.body.to_s
    end

    private_class_method :raise_on_error!, :raise_on_rate_limit!, :error_message

  end

end
