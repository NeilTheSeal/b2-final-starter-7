RSpec.describe "Merchant Coupons New Page" do
  before(:each) do
    @merchant = Merchant.create!(name: "Hair Care")

    visit "/merchants/#{@merchant.id}/coupons/new"
  end

  it "can add a new coupon to the merchant coupon list" do
    fill_in("name", with: "TwentyPercentOff")
    fill_in("code", with: "PO003")
    fill_in("discount", with: "20")
    select("percentage", from: "discount_type")
    click_button("submit")

    expect(page).to have_current_path("/merchants/#{@merchant.id}/coupons")

    within "#activated-coupon-list" do
      expect(page).to have_content("TwentyPercentOff")
      expect(page).to have_content("PO003")
      expect(page).to have_content("20%")
    end
  end

  describe "coupon creation sad paths" do
    before(:each) do
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
      select("percentage", from: "discount_type")
      click_button("submit")

      within "#deactivated-coupon-list" do
        expect(page).to have_content("TwentyPercentOff")
      end
    end

    it "does not create coupons with a non-unique code" do
      fill_in("name", with: "TwentyPercentOff")
      fill_in("code", with: "PO001")
      fill_in("discount", with: "20")
      select("percentage", from: "discount_type")
      click_button("submit")

      expect(page).to have_current_path("/merchants/#{@merchant.id}/coupons/new")
      expect(page).to have_content("Error: Coupon code must be unique.")
    end

    it "does not create coupons if any fields are blank" do
      fill_in("name", with: "")
      fill_in("code", with: "PO005")
      fill_in("discount", with: "20")
      select("percentage", from: "discount_type")
      click_button("submit")

      expect(page).to have_current_path("/merchants/#{@merchant.id}/coupons/new")
      expect(page).to have_content("Error:")
    end
  end
end
