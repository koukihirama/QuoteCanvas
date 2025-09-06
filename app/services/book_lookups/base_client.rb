module BookLookups
  class BaseClient
    DEFAULT_TIMEOUT = 5
    DEFAULT_OPEN_TIMEOUT = 3

    private

    def http
      @http ||= Faraday.new do |f|
        f.request :url_encoded
        f.response :follow_redirects
        f.adapter Faraday.default_adapter
        f.options.timeout = DEFAULT_TIMEOUT
        f.options.open_timeout = DEFAULT_OPEN_TIMEOUT
      end
    end

    def read_json(body)
      return {} if body.blank?
      if defined?(Oj)
        Oj.load(body, symbol_keys: true)
      else
        JSON.parse(body, symbolize_names: true)
      end
    end

    def compact_hash(h)
      h.compact_blank # Rails 7 から使える便利メソッド
    end
  end
end