class Api::BooksController < ApplicationController
  # 必要なら認可を later で
  def index
    if params[:isbn].present?
      results = BookLookups::FetchBookInfo.by_isbn(params[:isbn])
    elsif params[:title].present?
      results = BookLookups::FetchBookInfo.by_title_author(
        title: params[:title],
        author: params[:author]
      )
    else
      return render json: { error: "isbn もしくは title が必要です" }, status: :unprocessable_entity
    end

    render json: { results: results }, status: :ok
  end
end