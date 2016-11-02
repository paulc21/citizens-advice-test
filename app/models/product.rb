class Product < ApplicationRecord
  # Associations
  has_many :line_items
  has_many :orders, through: :line_items

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :net_price, presence: true
end
