class Passage < ApplicationRecord
  # 所有者
  belongs_to :user

  # 関連
  has_many :thought_logs, dependent: :destroy
  has_one  :customization,
           class_name: "PassageCustomization",
           dependent: :destroy,
           inverse_of: :passage

  # 作成/編集フォームでカスタマイズを一緒に受け取る
  accepts_nested_attributes_for :customization, update_only: true

  # バリデーション
  validates :content, presence: true, length: { maximum: 2000 }
  validates :title,   length: { maximum: 200 },  allow_blank: true
  validates :author,  length: { maximum: 120 },  allow_blank: true

  # 旧カラム（段階移行中なら残す）
  validates :bg_color, :text_color, :font_family, length: { maximum: 50 }, allow_blank: true
end