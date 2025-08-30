class PassagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_passage,   only: [:show, :edit, :update, :destroy]   # ← destroy追加
  before_action :ensure_owner!, only: [:edit, :update, :destroy]          # ← destroy追加

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

  def show; end
  def edit; end

  def update
    if @passage.update(passage_params)
      redirect_to @passage, notice: "カードを更新したよ。"
    else
      flash.now[:alert] = "更新に失敗しちゃった…入力を見直してね。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @passage.destroy
      redirect_to dashboard_path, notice: "カードを削除しました。"
    else
      redirect_to @passage, alert: "削除に失敗しちゃった…もう一度試してね。"
    end
  end

  private

  def set_passage
    @passage = Passage.find_by(id: params[:id])
    unless @passage
      redirect_to dashboard_path, alert: "カードが見つからないよ。" and return
    end
  end

  def ensure_owner!
    return if @passage.user_id == current_user.id
    redirect_to @passage, alert: "これはあなたのカードじゃないみたい…" and return
  end

  def passage_params
    params.require(:passage).permit(:content, :title, :author, :bg_color, :text_color, :font_family)
  end
end