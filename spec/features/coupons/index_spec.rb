require "rails_helper"

RSpec.describe "Merchant Coupons Index Page" do
  before(:each) do
    @merchant1 = Merchant.create!(name: "Hair Care")

    @coupon1 = Coupon.create!(
      name: "TenPercentOff",
      code: "PO001",
      discount_type: "percentage",
      discount: 10,
      status: "activated",
      merchant: @merchant1
    )

    @coupon2 = Coupon.create!(
      name: "TenDollarsOff",
      code: "DO001",
      discount_type: "dollar",
      discount: 1000,
      status: "activated",
      merchant: @merchant1
    )

    @coupon3 = Coupon.create!(
      name: "FifteenPercentOff",
      code: "PO002",
      discount_type: "percentage",
      discount: 15,
      status: "deactivated",
      merchant: @merchant1
    )

    @coupon4 = Coupon.create!(
      name: "FifteenDollarsOff",
      code: "DO002",
      discount_type: "dollar",
      discount: 1500,
      status: "deactivated",
      merchant: @merchant1
    )

    visit("/merchants/#{@merchant1.id}/coupons")
  end

  it "displays all of the coupon names including their amount" do
    within("#activated-coupon-list") do
      within("#coupon-#{@coupon1.id}") do
        expect(page).to have_content("TenPercentOff")
        expect(page).to have_content("Coupon Code: PO001")
        expect(page).to have_content("Discount: 10%")
      end

      within("#coupon-#{@coupon2.id}") do
        expect(page).to have_content("TenDollarsOff")
        expect(page).to have_content("Coupon Code: DO001")
        expect(page).to have_content("Discount: $10.00")
      end
    end

    within("#deactivated-coupon-list") do
      within("#coupon-#{@coupon3.id}") do
        expect(page).to have_content("FifteenPercentOff")
        expect(page).to have_content("Coupon Code: PO002")
        expect(page).to have_content("Discount: 15%")
      end

      within("#coupon-#{@coupon4.id}") do
        expect(page).to have_content("FifteenDollarsOff")
        expect(page).to have_content("Coupon Code: DO002")
        expect(page).to have_content("Discount: $15.00")
      end
    end
  end

  it "each coupon is a link to the coupon show page" do
    click_link("TenPercentOff")
    expect(page).to have_current_path(
      "/merchants/#{@merchant1.id}/coupons/#{@coupon1.id}"
    )
  end

  it "has a link to create a new coupon" do
    click_link("New Coupon")
    expect(page).to have_current_path(
      "/merchants/#{@merchant1.id}/coupons/new"
    )
  end
end
