module BookLookups
  class OpenLibraryClient < BaseClient
    SEARCH = "https://openlibrary.org/search.json"

    def by_isbn(isbn)
      res = conn.get(SEARCH, { isbn: digits_or_x(isbn), limit: 5 })
      normalize_search(res.body)
    rescue => e
      Rails.logger.error("OpenLibraryClient error: #{e.class} #{e.message}")
      []
    end

    def by_title_author(title:, author: nil)
      params = { title: title, author: author, limit: 5 }.compact
      res = conn.get(SEARCH, params)
      normalize_search(res.body)
    rescue => e
      Rails.logger.error("OpenLibraryClient error: #{e.class} #{e.message}")
      []
    end

    private

    def normalize_search(body)
      docs = Array(body["docs"])
      docs.map do |d|
        cover_url = d["cover_i"] ? "https://covers.openlibrary.org/b/id/#{d["cover_i"]}-M.jpg" : nil
        {
          source:         "open_library",
          source_id:      d["key"], # "/works/OLxxxxxW"
          title:          d["title"],
          authors:        Array(d["author_name"]),
          published_date: d["first_publish_year"]&.to_s, # 年のみ→後で補完
          page_count:     d["number_of_pages_median"],
          cover_url:      cover_url,
          publisher:      Array(d["publisher"]).first,
          isbn_10:        Array(d["isbn"]).find { |s| s&.length == 10 },
          isbn_13:        Array(d["isbn"]).find { |s| s&.length == 13 }
        }
      end
    end

    def digits_or_x(s)
      s.to_s.gsub(/[^0-9Xx]/, "")
    end
  end
end
