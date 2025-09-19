class PassagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_passage, only: %i[show edit update destroy]

  def index
    @passages = current_user.passages
                           .includes(:book_info, :customization)
                           .order(created_at: :desc)
  end

  def new
    @passage = current_user.passages.new
    @passage.build_customization unless @passage.customization
    @passage.build_book_info     unless @passage.book_info
  end

  def create
    normalize_nested_keys!

    @passage = current_user.passages.new
    @passage.build_book_info if @passage.book_info.nil? && params.dig(:passage, :book_info_attributes).present?
    @passage.build_customization(user: current_user) if @passage.customization.nil? && params.dig(:passage, :customization_attributes).present?

    @passage.assign_attributes(passage_params)
    @passage.customization&.user ||= current_user

    Rails.logger.info("[passages#create] book_info_attrs=#{params.dig(:passage, :book_info_attributes).inspect}")

    if @passage.save
      redirect_to @passage, notice: "カードを保存したよ。"
    else
      flash.now[:alert] = "保存に失敗しちゃった…入力を見直してね。"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    normalize_nested_keys!

    @passage.build_book_info if @passage.book_info.nil? && params.dig(:passage, :book_info_attributes).present?
    @passage.build_customization(user: current_user) if @passage.customization.nil? && params.dig(:passage, :customization_attributes).present?

    Rails.logger.info("[passages#update] book_info_attrs=#{params.dig(:passage, :book_info_attributes).inspect}")

    if @passage.update(passage_params)
      redirect_to @passage, notice: "カードを更新したよ。"
    else
      flash.now[:alert] = "更新に失敗しちゃった…入力を見直してね。"
      render :edit, status: :unprocessable_entity
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

  def destroy
    if @passage.destroy
      redirect_to dashboard_path, notice: "カードを削除しました。"
    else
      redirect_to @passage, alert: "削除に失敗しちゃった…もう一度試してね。"
    end
  end

  private

  def set_passage
    # 自分のレコード限定。存在しなければ 404
    @passage = current_user.passages.find(params[:id])
  end

  # ネストキーを attr 名に揃え、空値は nil に、全空なら破棄
  def normalize_nested_keys!
    psg = params[:passage]
    return unless psg.is_a?(ActionController::Parameters)

    # 旧キー -> *_attributes に寄せ替え
    psg[:customization_attributes] ||= psg.delete(:customization) if psg[:customization].present?
    psg[:book_info_attributes]     ||= psg.delete(:book_info)     if psg[:book_info].present?

    # ---- book_info ----
    if (b = psg[:book_info_attributes]).present?
      b = b.is_a?(ActionController::Parameters) ? b.dup : ActionController::Parameters.new(b)

      # published_date -> published_on / source_id -> api_id に統一
      b[:published_on] ||= b.delete(:published_date) || b.delete("published_date")
      b[:api_id]       ||= b.delete(:source_id)      || b.delete("source_id")

      # 空文字は nil に（DBの NULL として扱う）
      %i[title author published_on isbn cover_url publisher source api_id].each do |k|
        b[k] = nil if b[k].is_a?(String) && b[k].blank?
      end

      # すべて空ならネストごと捨てる（判定は to_unsafe_h）
      data = b.respond_to?(:to_unsafe_h) ? b.to_unsafe_h : b.to_h
      if data.except(:id, "id").values.compact.blank?
        psg.delete(:book_info_attributes)
      else
        psg[:book_info_attributes] = b
      end
    end

    # ---- customization ----
    if (c = psg[:customization_attributes]).present?
      c = c.is_a?(ActionController::Parameters) ? c.dup : ActionController::Parameters.new(c)
      %i[font color bg_color].each { |k| c[k] = nil if c[k].is_a?(String) && c[k].blank? }

      data = c.respond_to?(:to_unsafe_h) ? c.to_unsafe_h : c.to_h
      if data.except(:id, "id").values.compact.blank?
        psg.delete(:customization_attributes)
      else
        psg[:customization_attributes] = c
      end
    end
  end

  def passage_params
    params.require(:passage).permit(
      :content, :title, :author,
      :bg_color, :text_color, :font_family,
      customization_attributes: %i[id font color bg_color],
      book_info_attributes:     %i[id title author published_on isbn cover_url publisher source api_id]
    )
  end
end
