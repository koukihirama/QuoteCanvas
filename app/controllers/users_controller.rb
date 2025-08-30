class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @passages_count = @user.passages.count
    @recent_passages = @user.passages.order(created_at: :desc).limit(12)
  end
end
