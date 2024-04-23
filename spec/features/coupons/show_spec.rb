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
      status: 1
    )
    @invoice2 = @coupon.invoices.create!(
      customer: @customer,
      status: 1
    )
    @invoice3 = @coupon.invoices.create!(
      customer: @customer,
      status: 1
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
end
