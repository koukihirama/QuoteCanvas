class PassagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_passage,   only: [ :show, :edit, :update, :destroy ]
  before_action :ensure_owner!, only: [ :edit, :update, :destroy ]

  def new
    @passage = current_user.passages.new
    @passage.build_customization(user: current_user) unless @passage.customization
  end

  def create
    normalize_customization_key!
    @passage = current_user.passages.new(passage_params)
    @passage.customization&.user ||= current_user

    if @passage.save
      redirect_to @passage, notice: "カードを保存したよ。"
    else
      flash.now[:alert] = "保存に失敗しちゃった…入力を見直してね。"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @thought_logs = @passage.thought_logs.order(created_at: :desc)
    @style = {
      bg:   @passage.customization&.bg_color.presence || @passage.bg_color.presence    || "#F9FAFB",
      text: @passage.customization&.color.presence    || @passage.text_color.presence  || "#111827",
      font: @passage.customization&.font.presence     || @passage.font_family.presence || "var(--font-serif)"
    }
  end

  def edit
    @passage.build_customization(user: current_user) unless @passage.customization
  end

  def update
    normalize_customization_key!

    if @passage.customization.nil? && params.dig(:passage, :customization_attributes).present?
      @passage.build_customization(user: current_user)
    end

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
    @passage = current_user.passages.find(params[:id])   # ← ここだけ変更
  end

  def ensure_owner!
    return if @passage.user_id == current_user.id
    redirect_to @passage, alert: "これはあなたのカードじゃないみたい…" and return
  end

  # passage[customization] で来ても受けられるように変換
  def normalize_customization_key!
    c = params.dig(:passage, :customization)
    params[:passage][:customization_attributes] ||= c if c
  end

  def passage_params
    params.require(:passage).permit(
      :content, :title, :author,
      :bg_color, :text_color, :font_family,
      customization_attributes: [ :id, :font, :color, :bg_color ]
    )
  end
end
