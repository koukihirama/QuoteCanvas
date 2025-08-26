class Passage < ApplicationRecord
  belongs_to :user, optional: true  # 既存データを壊さないため一旦 optional。後で必須化OK

  validates :body, presence: true, length: { maximum: 2000 }
  validates :title, length: { maximum: 200 }, allow_blank: true
  validates :author, length: { maximum: 120 }, allow_blank: true
  validates :bg_color, :text_color, :font_family, length: { maximum: 50 }, allow_blank: true
end
