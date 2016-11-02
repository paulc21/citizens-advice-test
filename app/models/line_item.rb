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

  private
  def default_quantity
    self.quantity ||= 1
  end
end
