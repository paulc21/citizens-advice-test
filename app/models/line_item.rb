class LineItem < ApplicationRecord
  # Associations
  belongs_to :order
  belongs_to :product

  # Validations
  validates :quantity, numericality: { greater_than: 0, only_integer: true }

  # Callbacks
  before_validation :default_quantity

  # Methods
  delegate :name, to: :product
  delegate :net_price, to: :product

  def subtotal
    self.net_price * self.quantity
  end

  private
  def default_quantity
    self.quantity ||= 1
  end
end
