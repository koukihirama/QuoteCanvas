module BookLookups
  class BaseClient
    def initialize
      @conn = Faraday.new do |f|
        f.request :url_encoded
        # faraday_middleware が必要（Gemfile に `gem "faraday_middleware"`）
        f.response :json, content_type: /\bjson$/
        f.adapter Faraday.default_adapter
        f.options.timeout = 5
        f.options.open_timeout = 3
      end
    end

    private
    attr_reader :conn
  end
end
