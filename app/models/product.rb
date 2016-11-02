class Product < ApplicationRecord
  # Associations
  has_many :line_items
  has_many :orders, through: :line_items

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :net_price, presence: true

  # Methods
  def destroy
    if self.line_items.any?
      self.errors.add(:base,"Cannot delete a product once it has been ordered")
      return false
    else
      super
    end
  end
end
