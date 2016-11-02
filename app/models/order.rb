class Order < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :line_items
  has_many :products, through: :line_items

  # Validations
  validates :order_date, presence: true
  validate :order_date_in_future, on: :create

  # Callbacks
  before_validation :default_order_date
  
  # States
  include AASM
  aasm do
    state :draft, initial: true
    state :placed
    state :paid
    state :cancelled

    event :place do
      transitions from: [:draft], to: :placed
    end

    event :pay do
      transitions from: [:placed], to: :paid
    end

    event :cancel do
      transitions from: [:draft,:placed], to: :cancelled do
        guard do
          reason_provided?
        end
      end
    end
  end
  
  # Methods
  private
  def order_date_in_future
    unless self.order_date.blank?
      if self.order_date < Date.today
        self.errors.add(:order_date,"cannot be in the past")
      end
    end
  end

  def default_order_date
    self.order_date ||= Date.today
  end

  def reason_provided?
    self.cancel_reason.present?
  end
end
