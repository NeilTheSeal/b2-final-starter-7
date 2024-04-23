RSpec.describe "Merchant Coupons New Page" do
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

    @coupon3 = Coupon.create!(
      name: "FifteenPercentOff",
      code: "PO002",
      discount_type: "percentage",
      discount: 15,
      status: "activated",
      merchant: @merchant
    )

    @coupon4 = Coupon.create!(
      name: "FifteenDollarsOff",
      code: "DO002",
      discount_type: "dollar",
      discount: 1500,
      status: "activated",
      merchant: @merchant
    )

    visit "/merchants/#{@merchant.id}/coupons/new"
  end

  it "can add a new coupon to the merchant coupon list" do
    fill_in("name", with: "TwentyPercentOff")
    fill_in("code", with: "PO003")
    fill_in("discount", with: "20")
    choose("percentage")
    click_button("submit")

    expect(page).to have_current_path("/merchants/#{@merchant.id}/coupons")

    expect(page).to have_content("TwentyPercentOff")
    expect(page).to have_content("P003")
    expect(page).to have_content("20%")
    expect(page).to have_content("activated")
  end

  it "does not activate coupons if merchant has 5 already activated" do
    Coupon.create!(
      name: "TwentyDollarsOff",
      code: "DO003",
      discount_type: "dollar",
      discount: 2000,
      status: "activated",
      merchant: @merchant
    )

    fill_in("name", with: "TwentyPercentOff")
    fill_in("code", with: "PO003")
    fill_in("discount", with: "20")
    choose("percentage")
    click_button("submit")

    expect(page).to have_content("deactivated")
  end

  it "does not create coupons with a non-unique code" do
    fill_in("name", with: "TwentyPercentOff")
    fill_in("code", with: "PO001")
    fill_in("discount", with: "20")
    choose("percentage")
    click_button("submit")

    # save_and_open_page

    expect(page).to have_current_path("/merchants/#{@merchant.id}/coupons/new")
  end
end
