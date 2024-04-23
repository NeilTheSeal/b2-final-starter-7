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

  it "determines if a coupon code is unique" do
    expect(Coupon.unique?(code: "PO001")).to eq(false)
    expect(Coupon.unique?(code: "PO003")).to eq(true)
  end

  it "creates a deactivated coupon if 5 coupons are already active" do
    Coupon.create!(
      name: "15DollarsOff",
      code: "DO002",
      discount_type: "dollar",
      discount: 1500,
      status: "activated",
      merchant: @merchant
    )
    Coupon.create!(
      name: "20DollarsOff",
      code: "DO003",
      discount_type: "dollar",
      discount: 2000,
      status: "activated",
      merchant: @merchant
    )
    Coupon.create!(
      name: "25DollarsOff",
      code: "DO004",
      discount_type: "dollar",
      discount: 2500,
      status: "activated",
      merchant: @merchant
    )
    coupon = Coupon.create_new(
      name: "Test",
      code: "DO005",
      discount_type: "dollar",
      discount: 3000,
      merchant_id: @merchant.id
    )
    expect(coupon.status).to eq("deactivated")
    expect(coupon.save).to eq(true)
  end
end
