class PassageCustomizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_passage

  def new
    if @passage.customization
      redirect_to edit_passage_customization_path(@passage),
                  notice: "このカードには既にカスタマイズが設定されています。" and return
    end
    @customization = @passage.build_customization(user: current_user)
  end

  def create
    @customization = @passage.build_customization(customization_params.merge(user: current_user))
    if @customization.save
      redirect_to @passage, notice: "カスタマイズを保存したよ。"
    else
      flash.now[:alert] = "保存に失敗しちゃった…入力を見直してね。"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @customization = @passage.customization
    unless @customization
      redirect_to new_passage_customization_path(@passage),
                  notice: "まだカスタマイズがないので新規作成してね。" and return
    end
  end

  def update
    @customization = @passage.customization
    unless @customization
      redirect_to new_passage_customization_path(@passage),
                  alert: "先にカスタマイズを作成してから更新してね。" and return
    end

    if @customization.update(customization_params)
      redirect_to @passage, notice: "カスタマイズを更新したよ。"
    else
      flash.now[:alert] = "更新に失敗しちゃった…入力を見直してね。"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_passage
    # 所有者制約をここでかけてるので ensure_owner は不要
    @passage = current_user.passages.find(params[:passage_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "カードが見つからないよ。" and return
  end

  def customization_params
    params.require(:passage_customization).permit(:font, :color, :bg_color)
  end
end
