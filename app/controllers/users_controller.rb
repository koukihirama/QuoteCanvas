class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @passages_count = @user.passages.count
    @recent_passages =
      @user.passages
           .includes(:customization, :book_info) # ★ 追加
           .order(created_at: :desc)
           .limit(12)
  end

  def hide_guide
    current_user.update!(show_guide: false)
    head :ok
  end
end
