class PassagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_passage,   only: [ :show, :edit, :update, :destroy ]
  before_action :ensure_owner!, only: [ :edit, :update, :destroy ]

  def new
    @passage = current_user.passages.new
    @passage.build_customization(user: current_user) unless @passage.customization
  end

  def create
    normalize_nested_keys!

    # update_only 対策：未作成で attrs が来たら build
    @passage = current_user.passages.new
    @passage.build_customization(user: current_user) if @passage.customization.nil? && params.dig(:passage, :customization_attributes).present?
    @passage.build_book_info                         if @passage.book_info.nil?       && params.dig(:passage, :book_info_attributes).present?

    @passage.assign_attributes(passage_params)
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
  # ここを変更
  normalize_nested_keys!

  # customization が未作成なら先に build
  if @passage.customization.nil? && params.dig(:passage, :customization_attributes).present?
    @passage.build_customization(user: current_user)
  end

  # book_info が未作成なら先に build  ← 追加
  if @passage.book_info.nil? && params.dig(:passage, :book_info_attributes).present?
    @passage.build_book_info
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
  def normalize_nested_keys!
    if (c = params.dig(:passage, :customization)).present? && params.dig(:passage, :customization_attributes).blank?
      params[:passage][:customization_attributes] = c
    end
    if (b = params.dig(:passage, :book_info)).present? && params.dig(:passage, :book_info_attributes).blank?
      params[:passage][:book_info_attributes] = b
    end
  end

  def passage_params
    params.require(:passage).permit(
      :content, :title, :author,
      :bg_color, :text_color, :font_family,
      customization_attributes: [ :id, :font, :color, :bg_color ],
      # ← MVP最小（いまのスキーマに合わせる）
      book_info_attributes: [ :id, :title, :author, :published_date, :isbn ]
    )
  end
end
