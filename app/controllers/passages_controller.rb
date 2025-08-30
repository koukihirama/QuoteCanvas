class PassagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_passage, only: [:show, :edit, :update]
  before_action :ensure_owner!, only: [:edit, :update]

  def new
    @passage = current_user.passages.new
  end

  def create
    @passage = current_user.passages.new(passage_params)
    if @passage.save
      redirect_to @passage, notice: "カードを保存したよ。"
    else
      flash.now[:alert] = "保存に失敗しちゃった…入力を見直してね。"
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @passage.update(passage_params)
      redirect_to @passage, notice: "カードを更新したよ。"
    else
      flash.now[:alert] = "更新に失敗しちゃった…入力を見直してね。"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_passage
    @passage = Passage.find(params[:id])
  end

  def ensure_owner!
    redirect_to @passage, alert: "これはあなたのカードじゃないみたい…" unless @passage.user_id == current_user.id
  end

  def passage_params
    params.require(:passage).permit(:content, :title, :author, :bg_color, :text_color, :font_family)
  end
end