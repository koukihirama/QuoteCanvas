class PassageCustomization < ApplicationRecord
  belongs_to :passage
  belongs_to :user

  # HEXカラー簡易バリデーション
  HEX = /\A#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})\z/
  validates :bg_color, :color, allow_blank: true, format: { with: HEX, message: "は #RRGGBB 形式で入力してね" }

  validates :font, length: { maximum: 100 }, allow_blank: true
  validates :passage_id, uniqueness: true
end
