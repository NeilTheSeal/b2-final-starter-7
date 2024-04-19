require "rails_helper"

RSpec.describe "Merchant Coupons Index Page" do
  before(:each) do
    @merchant1 = Merchant.create!(name: "Hair Care")

    visit("/merchants/#{@merchant1.id}/coupons")
  end

  it "displays all of the coupon names including their amount off" do
  end
end
