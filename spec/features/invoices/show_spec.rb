require "rails_helper"

RSpec.describe "invoices show" do
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
      status: 2
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
      quantity: 10,
      unit_price: @item4.unit_price,
      status: 1
    )

    @transaction = Transaction.create!(
      credit_card_number: "000000000000",
      result: 1,
      invoice_id: @invoice.id
    )

    visit merchant_invoice_path(@merchant, @invoice)
  end

  it "shows the invoice information" do
    expect(page).to have_content(@invoice.id)
    expect(page).to have_content(@invoice.status)
    expect(page).to have_content(@invoice.created_at.strftime("%A, %B %-d, %Y"))
  end

  it "shows the customer information" do
    expect(page).to have_content(@customer.first_name)
    expect(page).to have_content(@customer.last_name)
    expect(page).to_not have_content(@customer2.last_name)
  end

  it "shows the item information" do
    expect(page).to have_content(@item1.name)
    expect(page).to have_content(@ii1.quantity)
    expect(page).to have_content("$10.00")
    expect(page).to_not have_content("$12.00")
  end

  it "shows the subtotal revenue for this invoice" do
    expect(page).to have_content("$220.00")
  end

  it "shows a select field to update the invoice status" do
    within("#the-status-#{@ii1.id}") do
      page.select("cancelled")
      click_button "Update Invoice"

      expect(page).to have_content("cancelled")
    end

    within("#current-invoice-status") do
      expect(page).to_not have_content("in progress")
    end
  end

  it "shows the coupon used for this invoice and has a link to the coupon's show page" do
    expect(page).to have_content("Coupon code: #{@coupon.code}")

    click_link @coupon.name

    expect(page).to have_current_path(merchant_coupon_path(@merchant, @coupon))
  end

  it "shows no coupon used if a coupon was not used" do
    visit merchant_invoice_path(@merchant, @invoice2)

    expect(page).to have_content("None")
  end

  it "shows the total revenue after the coupon was used" do
    expect(page).to have_content("Total Revenue: $198.00")
  end
end
