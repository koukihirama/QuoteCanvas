module BookLookups
  class GoogleBooksClient < BaseClient
    ENDPOINT = "https://www.googleapis.com/books/v1/volumes"

    def by_isbn(isbn)
      q = "isbn:#{digits_or_x(isbn)}"
      get_and_normalize(q:)
    end

    def by_title_author(title:, author: nil)
      parts = []
      parts << "intitle:#{title}"   if title.present?
      parts << "inauthor:#{author}" if author.present?
      return [] if parts.empty?
      get_and_normalize(q: parts.join("+"))
    end

    private

    def get_and_normalize(q:)
      params = { q: q }
      key = ENV["GOOGLE_BOOKS_API_KEY"].to_s.strip
      params[:key] = key if key.present?

      res = conn.get(ENDPOINT, params)
      Array(res.body["items"]).map { |it| normalize(it) }
    rescue => e
      Rails.logger.error("GoogleBooksClient error: #{e.class} #{e.message}")
      []
    end

    def normalize(item)
      vi = item["volumeInfo"] || {}
      ids = Array(vi["industryIdentifiers"])
      isbn10 = ids.find { |h| h["type"] == "ISBN_10" }&.dig("identifier")
      isbn13 = ids.find { |h| h["type"] == "ISBN_13" }&.dig("identifier")
      {
        source:         "google_books",
        source_id:      item["id"],
        title:          vi["title"],
        authors:        vi["authors"],
        published_date: vi["publishedDate"],
        description:    vi["description"],
        page_count:     vi["pageCount"].to_i,
        cover_url:      (vi["imageLinks"] || {})["thumbnail"],
        publisher:      vi["publisher"],
        isbn_10:        isbn10,
        isbn_13:        isbn13
      }
    end

    def digits_or_x(s)
      s.to_s.gsub(/[^0-9Xx]/, "")
    end
  end
end
