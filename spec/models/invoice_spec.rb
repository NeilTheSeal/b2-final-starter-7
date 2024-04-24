require "rails_helper"

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions }
  end
  describe "instance methods" do
    before(:each) do
      @merchant1 = Merchant.create!(name: "Hair Care")
      @merchant2 = Merchant.create!(name: "Other Dudes")

      @item1 = Item.create!(
        name: "Shampoo",
        description: "This washes your hair",
        unit_price: 1000,
        merchant_id: @merchant1.id,
        status: 1
      )

      @item2 = Item.create!(
        name: "Conditioner",
        description: "This makes your hair shiny",
        unit_price: 800,
        merchant_id: @merchant1.id
      )

      @item3 = Item.create!(
        name: "Brush",
        description: "This takes out tangles",
        unit_price: 500,
        merchant_id: @merchant2.id
      )

      @customer = Customer.create!(
        first_name: "Joey",
        last_name: "Smith"
      )

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

      @invoice = Invoice.create!(
        customer_id: @customer.id,
        status: 2,
        created_at: "2012-03-27 14:54:09"
      )

      @ii1 = InvoiceItem.create!(
        invoice_id: @invoice.id,
        item_id: @item1.id,
        quantity: 9,
        unit_price: @item1.unit_price,
        status: 2
      )

      @ii2 = InvoiceItem.create!(
        invoice_id: @invoice.id,
        item_id: @item2.id,
        quantity: 10,
        unit_price: @item2.unit_price,
        status: 1
      )

      @ii3 = InvoiceItem.create!(
        invoice_id: @invoice.id,
        item_id: @item3.id,
        quantity: 10,
        unit_price: @item3.unit_price,
        status: 1
      )

      @transaction = Transaction.create!(
        credit_card_number: "000000000000",
        result: 1,
        invoice_id: @invoice.id
      )
    end

    it "subtotal_revenue" do
      expect(@invoice.subtotal_revenue).to eq(22_000)
    end

    it "revenue from items with valid 10% off coupon" do
      @invoice.update(coupon_id: @coupon1.id)
      # (17000 * 0.9) = 15,300

      expect(@invoice.total_with_valid_coupons).to eq(15_300)
    end

    it "revenue from items with valid $10 off coupon" do
      @invoice.update(coupon_id: @coupon2.id)
      # 17,000 - 1000 = 16,000

      expect(@invoice.total_with_valid_coupons).to eq(16_000)
    end

    it "revenue from items with no valid coupon" do
      @invoice.update(coupon_id: @coupon1.id)

      expect(@invoice.total_without_valid_coupons).to eq(5000)
    end

    it "total_revenue - no coupon" do
      expect(@invoice.total_revenue).to eq(22_000)
    end

    it "total_revenue - 10% off coupon" do
      @invoice.update(coupon_id: @coupon1.id)
      # (17000 * 0.9) + 5000 = 20,300

      expect(@invoice.total_revenue).to eq(20_300)
    end

    it "total_revenue - $10 off coupon" do
      @invoice.update(coupon_id: @coupon2.id)
      # 22,000 - 1000 = 21,000

      expect(@invoice.total_revenue).to eq(21_000)
    end
  end
end
