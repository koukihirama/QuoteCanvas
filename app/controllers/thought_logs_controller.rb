class ThoughtLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_passage

  def new
    @thought_log = @passage.thought_logs.new
  end

  def create
    @thought_log = @passage.thought_logs.new(thought_log_params)
    if @thought_log.save
      redirect_to passage_path(@passage), notice: "思考ログを保存したよ。"
    else
      flash.now[:alert] = "保存に失敗しちゃった…入力を見直してね。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_passage
    @passage = Passage.find(params[:passage_id])
  end

  def thought_log_params
    params.require(:thought_log).permit(:content)
  end
end
