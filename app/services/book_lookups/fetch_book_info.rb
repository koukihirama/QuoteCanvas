module BookLookups
  class FetchBookInfo
    # 戻り値は「共通スキーマ（Hash）」の配列 or 単体（by_*_first）
    # 共通キー: :source, :source_id, :title, :authors(Array), :published_date, :isbn_10, :isbn_13, :description, :publisher, :page_count, :cover_url

    def self.by_isbn(isbn)
      new.by_isbn(isbn)
    end

    def self.by_title_author(title:, author: nil)
      new.by_title_author(title: title, author: author)
    end

    def by_isbn(isbn)
      Rails.cache.fetch(cache_key("isbn", isbn), expires_in: 6.hours) do
        (google.by_isbn(isbn) + openlib.by_isbn(isbn)).presence || []
      end
    end

    def by_title_author(title:, author: nil)
      key = [title, author].compact.join("|")
      Rails.cache.fetch(cache_key("ta", key), expires_in: 3.hours) do
        (google.by_title_author(title: title, author: author) +
         openlib.by_title_author(title: title, author: author)).presence || []
      end
    end

    # 「最初の1件だけ欲しい」ユース
    def by_isbn_first(isbn)
      by_isbn(isbn).first
    end

    def by_title_author_first(title:, author: nil)
      by_title_author(title: title, author: author).first
    end

    private

    def google
      @google ||= GoogleBooksClient.new
    end

    def openlib
      @openlib ||= OpenLibraryClient.new
    end

    def cache_key(type, key)
      "book_lookup:#{type}:#{Digest::SHA1.hexdigest(key.to_s)}"
    end
  end
end