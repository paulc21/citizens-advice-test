class User < ApplicationRecord
  # Associations
  has_many :orders
end
