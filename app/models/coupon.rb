class Coupon < ApplicationRecord
  validates_presence_of :name, :code, :discount_type, :discount, :status

  has_many :invoices
  belongs_to :merchant

  enum :discount_type, { percentage: 0, dollar: 1 }
  enum :status, { deactivated: 0, activated: 1 }

  def display_discount
    if discount_type == "percentage"
      "#{discount}%"
    else
      "$#{format('%.2f', discount.to_f / 100)}"
    end
  end
end
