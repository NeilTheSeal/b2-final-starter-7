require "rails_helper"

RSpec.describe "merchant dashboard" do
  before :each do
    @merchant1 = Merchant.create!(name: "Hair Care")

    @customer1 = Customer.create!(first_name: "Joey", last_name: "Smith")
    @customer2 = Customer.create!(first_name: "Cecilia", last_name: "Jones")
    @customer3 = Customer.create!(first_name: "Mariah", last_name: "Carrey")
    @customer4 = Customer.create!(first_name: "Leigh Ann", last_name: "Bron")
    @customer5 = Customer.create!(first_name: "Sylvester", last_name: "Nader")
    @customer6 = Customer.create!(first_name: "Herber", last_name: "Kuhn")

    @invoice1 = Invoice.create!(
      customer_id: @customer1.id,
      status: 2
    )
    @invoice2 = Invoice.create!(
      customer_id: @customer1.id,
      status: 2
    )
    @invoice3 = Invoice.create!(
      customer_id: @customer2.id,
      status: 2
    )
    @invoice4 = Invoice.create!(
      customer_id: @customer3.id,
      status: 2
    )
    @invoice5 = Invoice.create!(
      customer_id: @customer4.id,
      status: 2
    )
    @invoice6 = Invoice.create!(
      customer_id: @customer5.id,
      status: 2
    )
    @invoice7 = Invoice.create!(
      customer_id: @customer6.id,
      status: 1
    )

    @item1 = Item.create!(
      name: "Shampoo",
      description: "This washes your hair",
      unit_price: 10,
      merchant_id: @merchant1.id
    )
    @item2 = Item.create!(
      name: "Conditioner",
      description: "This makes your hair shiny",
      unit_price: 8,
      merchant_id: @merchant1.id
    )
    @item3 = Item.create!(
      name: "Brush",
      description: "This takes out tangles",
      unit_price: 5,
      merchant_id: @merchant1.id
    )
    @item4 = Item.create!(
      name: "Hair tie",
      description: "This holds up your hair",
      unit_price: 1,
      merchant_id: @merchant1.id
    )

    @ii1 = InvoiceItem.create!(
      invoice_id: @invoice1.id,
      item_id: @item1.id,
      quantity: 1,
      unit_price: 10,
      status: 0
    )
    @ii2 = InvoiceItem.create!(
      invoice_id: @invoice1.id,
      item_id: @item2.id,
      quantity: 1,
      unit_price: 8,
      status: 0
    )
    @ii3 = InvoiceItem.create!(
      invoice_id: @invoice2.id,
      item_id: @item3.id,
      quantity: 1,
      unit_price: 5,
      status: 2
    )
    @ii4 = InvoiceItem.create!(
      invoice_id: @invoice3.id,
      item_id: @item4.id,
      quantity: 1,
      unit_price: 5,
      status: 1
    )
    @ii5 = InvoiceItem.create!(
      invoice_id: @invoice4.id,
      item_id: @item4.id,
      quantity: 1,
      unit_price: 5,
      status: 1
    )
    @ii6 = InvoiceItem.create!(
      invoice_id: @invoice5.id,
      item_id: @item4.id,
      quantity: 1,
      unit_price: 5,
      status: 1
    )
    @ii7 = InvoiceItem.create!(
      invoice_id: @invoice6.id,
      item_id: @item4.id,
      quantity: 1,
      unit_price: 5,
      status: 1
    )

    @transaction1 = Transaction.create!(
      credit_card_number: 203_942,
      result: 1,
      invoice_id: @invoice1.id
    )
    @transaction2 = Transaction.create!(
      credit_card_number: 230_948,
      result: 1,
      invoice_id: @invoice3.id
    )
    @transaction3 = Transaction.create!(
      credit_card_number: 234_092,
      result: 1,
      invoice_id: @invoice4.id
    )
    @transaction4 = Transaction.create!(
      credit_card_number: 230_429,
      result: 1,
      invoice_id: @invoice5.id
    )
    @transaction5 = Transaction.create!(
      credit_card_number: 102_938,
      result: 1,
      invoice_id: @invoice6.id
    )
    @transaction6 = Transaction.create!(
      credit_card_number: 879_799,
      result: 1,
      invoice_id: @invoice7.id
    )
    @transaction7 = Transaction.create!(
      credit_card_number: 203_942,
      result: 1,
      invoice_id: @invoice2.id
    )

    visit merchant_dashboard_index_path(@merchant1)
  end

  it "shows the merchant name" do
    expect(page).to have_content(@merchant1.name)
  end

  it "can see a link to my merchant items index" do
    expect(page).to have_link("Items")

    click_link "Items"

    expect(current_path).to eq("/merchants/#{@merchant1.id}/items")
  end

  it "can see a link to my merchant invoices index" do
    expect(page).to have_link("Invoices")

    click_link "Invoices"

    expect(current_path).to eq("/merchants/#{@merchant1.id}/invoices")
  end

  it "shows the names of the top 5 customers with successful transactions" do
    within("#customer-#{@customer1.id}") do
      expect(page).to have_content(@customer1.first_name)
      expect(page).to have_content(@customer1.last_name)

      expect(page).to have_content(3)
    end
    within("#customer-#{@customer2.id}") do
      expect(page).to have_content(@customer2.first_name)
      expect(page).to have_content(@customer2.last_name)
      expect(page).to have_content(1)
    end
    within("#customer-#{@customer3.id}") do
      expect(page).to have_content(@customer3.first_name)
      expect(page).to have_content(@customer3.last_name)
      expect(page).to have_content(1)
    end
    within("#customer-#{@customer4.id}") do
      expect(page).to have_content(@customer4.first_name)
      expect(page).to have_content(@customer4.last_name)
      expect(page).to have_content(1)
    end
    within("#customer-#{@customer5.id}") do
      expect(page).to have_content(@customer5.first_name)
      expect(page).to have_content(@customer5.last_name)
      expect(page).to have_content(1)
    end
    expect(page).to have_no_content(@customer6.first_name)
    expect(page).to have_no_content(@customer6.last_name)
  end
  it "can see a section for Items Ready to Ship with list of names of items ordered and ids" do
    within("#items_ready_to_ship") do
      expect(page).to have_content(@item1.name)
      expect(page).to have_content(@ii1.invoice_id)

      expect(page).to have_content(@item2.name)
      expect(page).to have_content(@ii2.invoice_id)

      expect(page).to have_no_content(@item3.name)
      expect(page).to have_no_content(@ii3.invoice_id)
    end
  end

  it "each invoice id is a link to my merchant's invoice show page " do
    expect(page).to have_link(@ii1.invoice_id.to_s)
    expect(page).to have_link(@ii2.invoice_id.to_s)
    expect(page).to_not have_link(@ii3.invoice_id.to_s)

    click_link(@ii1.invoice_id.to_s, match: :first)
    expect(current_path).to eq("/merchants/#{@merchant1.id}/invoices/#{@invoice1.id}")
  end

  it "shows the date that the invoice was created in this format: Monday, July 18, 2019" do
    expect(page).to have_content(@invoice1.created_at.strftime("%A, %B %-d, %Y"))
  end

  it "has a link to view all the coupons" do
    click_link("Coupons")

    expect(page).to have_current_path("/merchants/#{@merchant1.id}/coupons")
  end
end
