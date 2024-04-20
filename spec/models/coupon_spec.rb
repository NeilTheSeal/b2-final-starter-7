require "rails_helper"

RSpec.describe Coupon, type: :model do
  before(:each) do
    @merchant = Merchant.create!(name: "Hair Care")

    @coupon1 = Coupon.create!(
      name: "TenPercentOff",
      code: "PO001",
      discount_type: "percentage",
      discount: 10,
      status: "activated",
      merchant: @merchant
    )

    @coupon2 = Coupon.create!(
      name: "TenDollarsOff",
      code: "DO001",
      discount_type: "dollar",
      discount: 1000,
      status: "activated",
      merchant: @merchant
    )
  end

  it "displays the discount as a formatted string" do
    expect(@coupon1.display_discount).to eq("10%")
    expect(@coupon2.display_discount).to eq("$10.00")
  end
end
