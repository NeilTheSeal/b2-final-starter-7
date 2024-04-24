class Invoice < ApplicationRecord
  validates_presence_of :status, :customer_id

  belongs_to :customer
  belongs_to :coupon, optional: true
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  enum status: %i[cancelled in_progress completed]

  def subtotal_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def total_revenue
    if coupon.nil?
      subtotal_revenue
    elsif coupon.discount_type == "percentage"
      (subtotal_revenue * (100 - coupon.discount) / 100).round(2)
    else
      [0, subtotal_revenue - coupon.discount].max
    end
  end
end
