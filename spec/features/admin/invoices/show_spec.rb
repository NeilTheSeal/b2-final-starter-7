require "rails_helper"

describe "Admin Invoices Index Page" do
  before :each do
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
    @item4 = Item.create!(
      name: "Thing",
      description: "It's a thing",
      unit_price: 1200,
      merchant_id: @merchant.id
    )

    @customer = Customer.create!(
      first_name: "Joey",
      last_name: "Smith"
    )

    @customer2 = Customer.create!(
      first_name: "Billy",
      last_name: "Jones"
    )

    @coupon = Coupon.create!(
      name: "TenPercentOff",
      code: "PO001",
      discount_type: "percentage",
      discount: 10,
      status: "activated",
      merchant: @merchant
    )

    @invoice = @coupon.invoices.create!(
      customer_id: @customer.id,
      status: 2,
      created_at: "2012-03-27 14:54:09"
    )

    @invoice2 = Invoice.create!(
      customer_id: @customer2.id,
      status: 2
    )

    @ii1 = InvoiceItem.create!(
      invoice_id: @invoice.id,
      item_id: @item1.id,
      quantity: 9,
      unit_price: @item1.unit_price,
      status: 0
    )

    # 9000

    @ii2 = InvoiceItem.create!(
      invoice_id: @invoice.id,
      item_id: @item2.id,
      quantity: 10,
      unit_price: @item2.unit_price,
      status: 1
    )

    # 8000

    @ii3 = InvoiceItem.create!(
      invoice_id: @invoice.id,
      item_id: @item3.id,
      quantity: 10,
      unit_price: @item3.unit_price,
      status: 1
    )

    # 5000

    @ii4 = InvoiceItem.create!(
      invoice_id: @invoice2.id,
      item_id: @item3.id,
      quantity: 123,
      unit_price: @item4.unit_price,
      status: 2
    )

    @transaction = Transaction.create!(
      credit_card_number: "000000000000",
      result: 1,
      invoice_id: @invoice.id
    )

    visit admin_invoice_path(@invoice)
  end

  it "should display the id, status and created_at" do
    expect(page).to have_content("Invoice ##{@invoice.id}")
    expect(page).to have_content("Created on: #{@invoice.created_at.strftime('%A, %B %d, %Y')}")

    expect(page).to_not have_content("Invoice ##{@invoice2.id}")
  end

  it "should display the customers name" do
    expect(page).to have_content(
      "#{@customer.first_name} #{@customer.last_name}"
    )

    expect(page).to_not have_content(
      "#{@customer2.first_name} #{@customer2.last_name}"
    )
  end

  it "should display all the items on the invoice" do
    expect(page).to have_content(@item1.name)
    expect(page).to have_content(@item2.name)

    expect(page).to have_content(@ii1.quantity)
    expect(page).to have_content(@ii2.quantity)
    expect(page).to have_content(@ii3.quantity)

    expect(page).to have_content("$10.00")
    expect(page).to have_content("$8.00")
    expect(page).to have_content("$5.00")

    expect(page).to have_content(@ii1.status)
    expect(page).to have_content(@ii2.status)
    expect(page).to have_content(@ii3.status)

    expect(page).to_not have_content(@ii4.quantity)
    expect(page).to_not have_content("$#{@ii4.unit_price}")
    expect(page).to_not have_content(@ii4.status)
  end

  it "should display the subtotal revenue the invoice will generate" do
    expect(page).to have_content("Subtotal Revenue: $220.00")

    expect(page).to_not have_content(@invoice2.subtotal_revenue)
  end

  it "should have status as a select field that updates the invoices status" do
    within("#status-update-#{@invoice.id}") do
      select("cancelled", from: "invoice[status]")
      expect(page).to have_button("Update Invoice")
      click_button "Update Invoice"

      expect(current_path).to eq(admin_invoice_path(@invoice))
      expect(@invoice.status).to eq("completed")
    end
  end

  it "shows the name of the coupon used for this invoice" do
    expect(page).to have_content(@coupon.name)
    expect(page).to have_content("Coupon code: #{@coupon.code}")
  end

  it "shows no coupon used if a coupon was not used" do
    @invoice.update(coupon_id: nil)

    visit admin_invoice_path(@invoice)

    expect(page).to have_content("None")
  end

  it "shows the total revenue after the coupon was used" do
    expect(page).to have_content("Total Revenue: $198.00")
  end
end
