class Passage < ApplicationRecord
  belongs_to :user, optional: true  # 後で必須化してOK
   has_many :thought_logs, dependent: :destroy

  validates :content, presence: true, length: { maximum: 2000 }
  validates :title, length: { maximum: 200 }, allow_blank: true
  validates :author, length: { maximum: 120 }, allow_blank: true
  validates :bg_color, :text_color, :font_family,
            length: { maximum: 50 }, allow_blank: true
end
