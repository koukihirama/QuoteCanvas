class BookInfosController < ApplicationController
  def search
    if params[:q].present?
      @results = BookLookups::FetchBookInfo.by_title_author(title: params[:q], author: nil)
    else
      @results = []
    end
  rescue => e
    Rails.logger.error(e)
    @results = []
    flash.now[:alert] = "検索中にエラーが発生しました"
  end
end
