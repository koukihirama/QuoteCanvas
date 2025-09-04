class PassageCustomizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_passage

  def new
    return redirect_to(edit_passage_customization_path(@passage),
                       notice: "このカードには既にカスタマイズが設定されています。") if @passage.customization
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
    @customization = @passage.customization or return redirect_to(new_passage_customization_path(@passage))
  end

  def update
    @customization = @passage.customization
    if @customization.update(customization_params)
      redirect_to @passage, notice: "カスタマイズを更新したよ。"
    else
      flash.now[:alert] = "更新に失敗しちゃった…入力を見直してね。"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_passage
    # 自分のカードだけ操作可
    @passage = current_user.passages.find(params[:passage_id])
  end

  def customization_params
    # 空文字は nil にして扱いやすく
    cleaned = params.require(:passage_customization).permit(:font, :color, :bg_color).to_h
    cleaned.transform_values! { |v| v.is_a?(String) && v.strip == "" ? nil : v }
    cleaned
  end
end
