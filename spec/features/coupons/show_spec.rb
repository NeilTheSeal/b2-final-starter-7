require "rails_helper"

RSpec.describe "Merchant Coupon Show Page" do
  before(:each) do
    @merchant = Merchant.create!(name: "Hair Style")

    @coupon = @merchant.coupons.create!(
      name: "FiftyDollarsOff",
      code: "DO001",
      discount: 5000,
      discount_type: 1,
      status: 1
    )

    @customer = create(:customer)

    @invoice1 = @coupon.invoices.create!(
      customer: @customer,
      status: 0
    )
    @invoice2 = @coupon.invoices.create!(
      customer: @customer,
      status: 0
    )
    @invoice3 = @coupon.invoices.create!(
      customer: @customer,
      status: 0
    )

    @transaction1 = Transaction.create!(
      invoice: @invoice1,
      credit_card_number: "0000000000000000",
      credit_card_expiration_date: "01/25",
      result: 0
    )
    @transaction2 = Transaction.create!(
      invoice: @invoice2,
      credit_card_number: "0000000000000000",
      credit_card_expiration_date: "01/25",
      result: 1
    )
    @transaction3 = Transaction.create!(
      invoice: @invoice2,
      credit_card_number: "0000000000000000",
      credit_card_expiration_date: "01/25",
      result: 0
    )
    @transaction3 = Transaction.create!(
      invoice: @invoice3,
      credit_card_number: "0000000000000000",
      credit_card_expiration_date: "01/25",
      result: 1
    )

    visit merchant_coupon_path(@merchant, @coupon)
  end

  it "displays the coupon info and the times the coupon has been used" do
    expect(page).to have_content("FiftyDollarsOff")
    expect(page).to have_content("Coupon Code: DO001")
    expect(page).to have_content("Discount: $50.00")
    expect(page).to have_content("Status: activated")
    expect(page).to have_content("This coupon has been used 2 times.")
  end

  it "has a button to enable/disable the coupon" do
    click_button("deactivate")

    expect(page).to have_current_path(merchant_coupon_path(@merchant, @coupon))
    expect(page).to have_content("Status: deactivated")

    click_button("activate")
    expect(page).to have_current_path(merchant_coupon_path(@merchant, @coupon))
    expect(page).to have_content("Status: activated")
  end

  it "cannot deactivate coupons with pending invoices" do
    @invoice1.update(status: 1)

    click_button("deactivate")

    expect(page).to have_content(
      "Error: cannot deactivate a coupon with pending invoices."
    )
  end

  it "cannot activate a coupon with 5 activated coupons" do
    @coupon.update(status: 0)

    visit merchant_coupon_path(@merchant, @coupon)

    Coupon.create!(
      name: "TenPercentOff",
      code: "PO001",
      discount_type: "percentage",
      discount: 10,
      status: "activated",
      merchant: @merchant
    )

    Coupon.create!(
      name: "TenDollarsOff",
      code: "DO002",
      discount_type: "dollar",
      discount: 1000,
      status: "activated",
      merchant: @merchant
    )

    Coupon.create!(
      name: "FifteenPercentOff",
      code: "PO002",
      discount_type: "percentage",
      discount: 15,
      status: "activated",
      merchant: @merchant
    )

    Coupon.create!(
      name: "FifteenDollarsOff",
      code: "DO003",
      discount_type: "dollar",
      discount: 1500,
      status: "activated",
      merchant: @merchant
    )

    Coupon.create!(
      name: "TwentyDollarsOff",
      code: "DO004",
      discount_type: "dollar",
      discount: 1500,
      status: "activated",
      merchant: @merchant
    )

    click_button("activate")

    expect(page).to have_content(
      "Error: cannot activate more than 5 coupons."
    )
  end
end
