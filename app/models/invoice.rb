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
    else
      total_with_valid_coupons + total_without_valid_coupons
    end
  end

  def total_with_valid_coupons
    if coupon.discount_type == "percentage"
      invoice_items.joins(invoice: :coupon, item: :merchant)
                   .where("coupons.merchant_id = items.merchant_id")
                   .sum("invoice_items.quantity * invoice_items.unit_price * (100 - discount) / 100")
    elsif coupon.discount_type == "dollar"
      total = invoice_items.joins(invoice: :coupon, item: :merchant)
                           .where("coupons.merchant_id = items.merchant_id")
                           .sum("invoice_items.unit_price * invoice_items.quantity")
      [0, total - coupon.discount].max
    end
  end

  def total_without_valid_coupons
    invoice_items.joins(invoice: :coupon, item: :merchant)
                 .where("coupons.merchant_id != items.merchant_id")
                 .sum("invoice_items.unit_price * invoice_items.quantity")
  end
end
