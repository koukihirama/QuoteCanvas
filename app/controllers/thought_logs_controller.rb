class ThoughtLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_passage

  def new
    @thought_log = @passage.thought_logs.new
  end

  def create
    @thought_log = @passage.thought_logs.build(thought_log_params.merge(user: current_user))
    if @thought_log.save
      redirect_to @passage, notice: "思考ログを保存したよ。"
    else
      flash.now[:alert] = "保存に失敗しちゃった…入力を見直してね。"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_passage
    @passage = current_user.passages.find(params[:passage_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "このカードは見つからないか、あなたのものではありません。"
  end

  def thought_log_params
    params.require(:thought_log).permit(:content)
  end
end
