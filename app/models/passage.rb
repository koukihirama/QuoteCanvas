class Passage < ApplicationRecord
  belongs_to :user

  has_one  :book_info,
           dependent: :destroy,
           inverse_of: :passage

  has_many :thought_logs, dependent: :destroy

  has_one  :customization,
           class_name: "PassageCustomization",
           dependent: :destroy,
           inverse_of: :passage

  accepts_nested_attributes_for :customization, update_only: true
  accepts_nested_attributes_for :book_info,     update_only: true

  validates :content, presence: true, length: { maximum: 2000 }
  validates :title,   length: { maximum: 200 },  allow_blank: true
  validates :author,  length: { maximum: 120 },  allow_blank: true

  validates :bg_color, :text_color, :font_family, length: { maximum: 50 }, allow_blank: true
end
