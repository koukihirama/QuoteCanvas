module BookLookups
  class OpenLibraryClient < BaseClient
    BASE = "https://openlibrary.org"

    def by_isbn(isbn)
      # 詳細: /isbn/{isbn}.json
      res = http.get("#{BASE}/isbn/#{isbn}.json")
      return [] unless res.success?

      json = read_json(res.body)
      [normalize_from_isbn(json, isbn)].compact
    rescue Faraday::Error
      []
    end

    def by_title_author(title:, author: nil)
      # シンプル検索: /search.json?q=...
      query = [title, author].compact.join(" ")
      res = http.get("#{BASE}/search.json", { q: query, limit: 5 })
      return [] unless res.success?

      json = read_json(res.body)
      Array(json[:docs]).first(5).map { |doc| normalize_from_search(doc) }.compact
    rescue Faraday::Error
      []
    end

    private

    def normalize_from_isbn(json, isbn)
      # 追加情報（authorsやcovers）を辿るのは後続イシューで拡張可
      {
        source: "open_library",
        source_id: json[:key],
        title: json[:title],
        authors: Array(json[:authors]).map { |a| a[:name] }.compact.presence, # 無いことも多い
        published_date: Array(json[:publish_date]).first || json[:publish_date],
        isbn_10: pick_isbn(json, :isbn_10),
        isbn_13: pick_isbn(json, :isbn_13) || (isbn.to_s.length == 13 ? isbn : nil),
        description: (json[:description].is_a?(Hash) ? json.dig(:description, :value) : json[:description]),
        publisher: Array(json[:publishers]).first,
        page_count: json[:number_of_pages],
        cover_url: openlib_cover_url(json)
      }.compact_blank
    end

    def normalize_from_search(doc)
      {
        source: "open_library",
        source_id: doc[:key],
        title: doc[:title],
        authors: Array(doc[:author_name]),
        published_date: Array(doc[:publish_date]).first,
        isbn_10: Array(doc[:isbn]).find { |i| i.to_s.length == 10 },
        isbn_13: Array(doc[:isbn]).find { |i| i.to_s.length == 13 },
        description: nil,
        publisher: Array(doc[:publisher]).first,
        page_count: doc[:number_of_pages_median],
        cover_url: openlib_cover_url_from_doc(doc)
      }.compact_blank
    end

    def pick_isbn(json, key)
      v = json[key]
      v.is_a?(Array) ? v.first : v
    end

    def openlib_cover_url(json)
      cover_id = Array(json[:covers]).first
      return nil unless cover_id
      # Mサイズを採用（S/M/L）
      "https://covers.openlibrary.org/b/id/#{cover_id}-M.jpg"
    end

    def openlib_cover_url_from_doc(doc)
      cover_id = doc[:cover_i]
      return nil unless cover_id
      "https://covers.openlibrary.org/b/id/#{cover_id}-M.jpg"
    end
  end
end