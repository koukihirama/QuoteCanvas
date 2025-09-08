class BookInfo < ApplicationRecord
  belongs_to :passage, inverse_of: :book_info

  validates :title, length: { maximum: 255 }, allow_blank: true
  validates :author, length: { maximum: 255 }, allow_blank: true
  validates :isbn, length: { maximum: 32 }, allow_blank: true
end
