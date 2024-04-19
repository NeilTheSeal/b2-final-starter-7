class Coupon < ApplicationRecord
  validates_presence_of :name, :code, :discount_type, :discount, :status

  has_many :invoices
  belongs_to :merchant
end
