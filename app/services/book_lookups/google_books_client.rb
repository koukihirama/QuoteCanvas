module BookLookups
  class GoogleBooksClient < BaseClient
    ENDPOINT = "https://www.googleapis.com/books/v1/volumes"

    def by_isbn(isbn)
      q = "isbn:#{isbn}"
      fetch(q)
    end

    def by_title_author(title:, author: nil)
      parts = []
      parts << "intitle:#{title}" if title.present?
      parts << "inauthor:#{author}" if author.present?
      q = parts.presence&.join("+") || title
      fetch(q)
    end

    private

    def fetch(q)
      params = { q: q, maxResults: 5 }
      key = ENV["GOOGLE_BOOKS_API_KEY"].to_s
      params[:key] = key if key.present?

      res = http.get(ENDPOINT, params)
      return [] unless res.success?

      json = read_json(res.body)
      Array(json[:items]).map { |item| normalize(item) }.compact
    rescue Faraday::Error
      []
    end

    # Google → 共通スキーマへ
    def normalize(item)
      v = item[:volumeInfo] || {}
      ids = Array(v[:industryIdentifiers]).index_by { |id| id[:type] } rescue {}
      isbn_10 = ids&.dig("ISBN_10", :identifier)
      isbn_13 = ids&.dig("ISBN_13", :identifier)

      {
        source: "google_books",
        source_id: item[:id],
        title: v[:title],
        authors: Array(v[:authors]),
        published_date: v[:publishedDate],
        isbn_10: isbn_10,
        isbn_13: isbn_13,
        description: v[:description],
        publisher: v[:publisher],
        page_count: v[:pageCount],
        cover_url: v.dig(:imageLinks, :thumbnail) || v.dig(:imageLinks, :smallThumbnail)
      }.compact_blank
    end
  end
end