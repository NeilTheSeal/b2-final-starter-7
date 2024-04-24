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
      @merchant = Merchant.create!(name: "Hair Care")

      @item1 = Item.create!(
        name: "Shampoo",
        description: "This washes your hair",
        unit_price: 1000,
        merchant_id: @merchant.id,
        status: 1
      )

      @item2 = Item.create!(
        name: "Conditioner",
        description: "This makes your hair shiny",
        unit_price: 800,
        merchant_id: @merchant.id
      )

      @item3 = Item.create!(
        name: "Brush",
        description: "This takes out tangles",
        unit_price: 500,
        merchant_id: @merchant.id
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

    it "total_revenue - no coupon" do
      expect(@invoice.total_revenue).to eq(22_000)
    end

    it "total_revenue - 10% off coupon" do
      @invoice.update(coupon_id: @coupon1.id)
      expect(@invoice.total_revenue).to eq(19_800)
    end

    it "total_revenue - $10 off coupon" do
      @invoice.update(coupon_id: @coupon2.id)
      expect(@invoice.total_revenue).to eq(21_000)
    end
  end
end
