require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :code }
    it { should validate_presence_of :discount_type }
    it { should validate_presence_of :discount }
    it { should validate_presence_of :status }
  end
  describe "relationships" do
    it { should belong_to :merchant }
    it { should have_many :invoices }
  end

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

    @customer = create(:customer)

    @invoice1 = @coupon1.invoices.create!(
      customer: @customer,
      status: 1
    )
    @invoice2 = @coupon1.invoices.create!(
      customer: @customer,
      status: 1
    )
    @invoice3 = @coupon1.invoices.create!(
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

  it "counts the number of successful transactions with the coupon" do
    expect(@coupon1.count_uses).to eq(2)
  end

  it "can activate a coupon" do
    coupon = Coupon.create!(
      name: "Test",
      code: "DO005",
      discount_type: "dollar",
      discount: 3000,
      merchant: @merchant,
      status: "deactivated"
    )

    expect(coupon.attempt_update("activated")).to eq(true)
  end

  it "can deactivate a coupon" do
    @invoice1.update(status: "completed")
    @invoice2.update(status: "completed")
    @invoice3.update(status: "cancelled")

    expect(@coupon1.attempt_update("deactivated")).to eq(true)
  end

  it "returns an error when the coupon cannot be activated" do
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

    expect(coupon.attempt_update("activated")).to eq(
      "Error: cannot activate more than 5 coupons."
    )
  end

  it "cannot deactivate a coupon with pending invoices" do
    expect(@coupon1.attempt_update("deactivated")).to eq(
      "Error: cannot deactivate a coupon with pending invoices."
    )
  end
end
