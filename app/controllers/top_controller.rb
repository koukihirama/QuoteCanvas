class TopController < ApplicationController
  def index
    @latest_passages = Passage.order(created_at: :desc).limit(5)
  end
end
