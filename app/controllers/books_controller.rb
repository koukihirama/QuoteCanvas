class BooksController < ApplicationController
  def lookup
    q = params.permit(:isbn, :title, :author)
    results =
      if q[:isbn].present?
        BookLookups::FetchBookInfo.by_isbn(q[:isbn])
      else
        BookLookups::FetchBookInfo.by_title_author(title: q[:title], author: q[:author])
      end
    render json: { items: results }
  rescue => e
    Rails.logger.error(e)
    render json: { items: [], error: "lookup_failed" }, status: :bad_gateway
  end
end