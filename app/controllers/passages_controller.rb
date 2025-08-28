class PassagesController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]
  before_action :set_passage, only: [ :show ]

  def new
    @passage = current_user.passages.build
  end

  def create
    @passage = current_user.passages.build(passage_params)
    if @passage.save
      redirect_to dashboard_path, notice: "一節を保存しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    # 公開/非公開の概念がなければそのまま表示
    # 自分のものだけ見せたいなら以下のような制約を後で入れる
    # redirect_to root_path, alert: "権限がありません" unless @passage.user_id == current_user&.id
  end

  private

  def set_passage
    @passage = Passage.find(params[:id])
  end

  def passage_params
    params.require(:passage).permit(:content, :title, :author, :bg_color, :text_color, :font_family)
  end
end
