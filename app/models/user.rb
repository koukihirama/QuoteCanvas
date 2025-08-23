class User < ApplicationRecord
  validates :name, length: { maximum: 30 }, allow_blank: true
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
