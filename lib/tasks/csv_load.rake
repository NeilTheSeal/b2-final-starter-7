require "csv"
namespace :csv_load do
  task clear_db: :environment do
    Transaction.destroy_all
    InvoiceItem.destroy_all
    Item.destroy_all
    Invoice.destroy_all
    Coupon.destroy_all
    Merchant.destroy_all
    Customer.destroy_all
  end

  task customers: :environment do
    CSV.foreach("db/data/customers.csv", headers: true) do |row|
      Customer.create!(row.to_hash)
    end
    ActiveRecord::Base.connection.reset_pk_sequence!("customers")
    puts "Customers imported."
  end

  task merchants: :environment do
    CSV.foreach("db/data/merchants.csv", headers: true) do |row|
      Merchant.create!(row.to_hash)
    end
    ActiveRecord::Base.connection.reset_pk_sequence!("merchants")
    puts "Merchants imported."
  end

  task items: :environment do
    CSV.foreach("db/data/items.csv", headers: true) do |row|
      Item.create!(id: row.to_hash["id"], name: row.to_hash["name"],
                   description: row.to_hash["description"], unit_price: row.to_hash["unit_price"].to_f / 100, created_at: row.to_hash["created_at"], updated_at: row.to_hash["updated_at"], merchant_id: row.to_hash["merchant_id"], status: 1)
    end
    ActiveRecord::Base.connection.reset_pk_sequence!("items")
    puts "Items imported."
  end

  task invoices: :environment do
    CSV.foreach("db/data/invoices.csv", headers: true) do |row|
      case row.to_hash["status"]
      when "cancelled"
        status = 0
      when "in progress"
        status = 1
      when "completed"
        status = 2
      end
      Invoice.create!({ id: row[0],
                        customer_id: row[1],
                        status:,
                        created_at: row[4],
                        updated_at: row[5] })
    end
    ActiveRecord::Base.connection.reset_pk_sequence!("invoices")
    puts "Invoices imported."
  end

  task transactions: :environment do
    CSV.foreach("db/data/transactions.csv", headers: true) do |row|
      if row.to_hash["result"] == "failed"
        result = 0
      elsif row.to_hash["result"] == "success"
        result = 1
      end
      Transaction.create!({ id: row[0],
                            invoice_id: row[1],
                            credit_card_number: row[2],
                            credit_card_expiration_date: row[3],
                            result:,
                            created_at: row[5],
                            updated_at: row[6] })
    end
    ActiveRecord::Base.connection.reset_pk_sequence!("transactions")
    puts "Transactions imported."
  end

  task invoice_items: :environment do
    CSV.foreach("db/data/invoice_items.csv", headers: true) do |row|
      case row.to_hash["status"]
      when "pending"
        status = 0
      when "packaged"
        status = 1
      when "shipped"
        status = 2
      end
      InvoiceItem.create!({ id: row[0],
                            item_id: row[1],
                            invoice_id: row[2],
                            quantity: row[3],
                            unit_price: row[4],
                            status:,
                            created_at: row[6],
                            updated_at: row[7] })
    end
    ActiveRecord::Base.connection.reset_pk_sequence!("invoice_items")
    puts "InvoiceItems imported."
  end

  task coupons: :environment do
    CSV.foreach("db/data/coupons.csv", headers: true) do |row|
      discount_type = row[3] == "percentage" ? 0 : 1
      status = row[5] == "deactivated" ? 0 : 1

      Coupon.create!({
        id: row[0],
        name: row[1],
        code: row[2],
        discount_type:,
        discount: row[4],
        status:,
        merchant_id: row[6],
        created_at: row[7],
        updated_at: row[8]
      })
    end
    ActiveRecord::Base.connection.reset_pk_sequence!("coupons")
    puts "Coupons imported."
  end

  task add_coupons: :environment do
    Merchant.find(1).invoices.each do |invoice|
      invoice.update(coupon_id: 1)
    end

    Merchant.find(2).invoices.each do |invoice|
      invoice.update(coupon_id: 2)
    end

    Merchant.find(3).invoices.each do |invoice|
      invoice.update(coupon_id: 3)
    end

    Merchant.find(4).invoices.each do |invoice|
      invoice.update(coupon_id: 4)
    end

    Merchant.find(5).invoices.each do |invoice|
      invoice.update(coupon_id: 5)
    end
  end

  task :all do
    %i[clear_db customers merchants coupons invoices items invoice_items
       transactions add_coupons].each do |task|
      Rake::Task["csv_load:#{task}"].invoke
    end
  end
end
