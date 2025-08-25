class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Passageモデル と User#passages の両方があるときだけ触る
    if defined?(Passage) && current_user.respond_to?(:passages)
      scope = current_user.passages.order(created_at: :desc)
      @recent_passages = scope.limit(3)
      @passages_count  = scope.count
    else
      @recent_passages = []
      @passages_count  = 0
    end
  end
end
