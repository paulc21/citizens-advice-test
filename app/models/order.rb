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
  before_validation :default_vat_rate
  
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

  # Scopes
  scope :active, ->() { where.not(aasm_state:["draft","cancelled"]) }
  
  # Methods
  def net_total
    self.line_items.map{|i| i.net_price * i.quantity }.sum
  end

  def vat_total
    self.net_total * self.vat_percentage
  end

  def gross_total
    self.net_total + self.vat_total
  end

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

  def default_vat_rate
    self.vat_percentage ||= VAT_DEFAULT
  end

  def reason_provided?
    self.cancel_reason.present?
  end
end
