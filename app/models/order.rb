class Order < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :line_items

  # Validations
  validate :order_date_in_future
    
  # Callbacks
  # Scopes
  # Methods
  private
  def order_date_in_future
    if self.order_date < Date.today
      self.errors.add(:order_date,"cannot be in the past")
    end
  end
end
