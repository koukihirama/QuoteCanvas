class PassagesController < ApplicationController
  def new
    @passage = Passage.new
  end

  def create
  @passage = current_user.passages.build(passage_params)
  if @passage.save
    redirect_to dashboard_path, notice: "一節を保存しました！"
  else
    render :new, status: :unprocessable_entity
  end
end

  private

  def passage_params
    params.require(:passage).permit(:content)
  end
end