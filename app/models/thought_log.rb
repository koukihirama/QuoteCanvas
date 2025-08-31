class ThoughtLog < ApplicationRecord
  belongs_to :passage

  validates :content, presence: true, length: { maximum: 10_000 }
end
