class Passage < ApplicationRecord
  belongs_to :user, optional: true  # 既存データを壊さないため一旦 optional。後で必須化OK

  # 移行中は content を必須にする
  validates :content, presence: true, length: { maximum: 2000 }

  validates :title, length: { maximum: 200 }, allow_blank: true
  validates :author, length: { maximum: 120 }, allow_blank: true
  validates :bg_color, :text_color, :font_family, length: { maximum: 50 }, allow_blank: true

  # 旧bodyカラムに互換を持たせたい場合は補完
  before_validation do
    self.content = body if content.blank? && body.present?
    self.body    = content if body.blank? && content.present?
  end
end
