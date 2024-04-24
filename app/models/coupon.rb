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

  def count_uses
    invoices.joins(:transactions).where("transactions.result = 1").count
  end

  def attempt_update(status)
    if status == "deactivated" && invoices.where("invoices.status = 1").count.positive?
      "Error: cannot deactivate a coupon with pending invoices."
    elsif status == "activated" && merchant.coupons.where("coupons.status = 1").count >= 5
      "Error: cannot activate more than 5 coupons."
    else
      update(status:)
    end
  end

  def self.unique?(params)
    !Coupon.find_by(code: params[:code])
  end

  def self.create_new(params)
    merchant = Merchant.find(params[:merchant_id])
    params[:status] = "deactivated" if merchant.count_active_coupons >= 5

    Coupon.new(params)
  end
end
