class CouponsController < ApplicationController
  def index
    @merchant = Merchant.find(params[:merchant_id])
  end

  def show
    @merchant = Merchant.find(params[:merchant_id])
    @coupon = Coupon.find(params[:id])
  end

  def new
    @merchant = Merchant.find(params[:merchant_id])
  end

  def create
    coupon = Coupon.create_new(new_coupon_params)
    merchant = Merchant.find(params[:merchant_id])

    if !Coupon.unique?(new_coupon_params)
      flash[:alert] = "Error: Coupon code must be unique."
      redirect_to new_merchant_coupon_path(merchant_id: merchant.id)
    elsif coupon.save
      redirect_to merchant_coupons_path(merchant_id: merchant.id)
    else
      flash[:alert] = "Error: #{coupon.errors.full_messages}"
      redirect_to new_merchant_coupon_path(merchant_id: merchant.id)
    end
  end

  def update
    merchant = Merchant.find(params[:merchant_id])
    coupon = Coupon.find(params[:id])

    result = coupon.attempt_update(params[:status])

    flash[:alert] = result unless result == true

    redirect_to merchant_coupon_path(merchant, coupon)
  end

  private

  def new_coupon_params
    params.permit(:id, :name, :code, :discount, :discount_type, :merchant_id)
  end
end
