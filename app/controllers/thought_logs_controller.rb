# app/controllers/thought_logs_controller.rb
class ThoughtLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_passage
  before_action :set_thought_log, only: :destroy

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

  def destroy
    @thought_log.destroy!
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@thought_log) }
      format.html { redirect_to passage_path(@passage), notice: "思考ログを削除しました。" }
    end
  end

  private

  def set_passage
    @passage = current_user.passages.find(params[:passage_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "このカードは見つからないか、あなたのものではありません。"
  end

  def set_thought_log
    @thought_log = @passage.thought_logs.find(params[:id])
  end

  def thought_log_params
    params.require(:thought_log).permit(:content)
  end
end
