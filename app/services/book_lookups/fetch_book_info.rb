module BookLookups
  class FetchBookInfo
    class << self
      def by_isbn(isbn)
        merge(
          GoogleBooksClient.new.by_isbn(isbn),
          OpenLibraryClient.new.by_isbn(isbn)
        )
      end

      def by_title_author(title:, author: nil)
        merge(
          GoogleBooksClient.new.by_title_author(title:, author:),
          OpenLibraryClient.new.by_title_author(title:, author:)
        )
      end

      private

      def merge(*arrays)
        seen = {}
        arrays.flatten.compact.select do |it|
          key = it[:isbn_13].presence || it[:isbn_10].presence || "#{it[:source]}:#{it[:source_id]}"
          next false unless key
          !seen[key] && (seen[key] = true)
        end
      end
    end
  end
end
