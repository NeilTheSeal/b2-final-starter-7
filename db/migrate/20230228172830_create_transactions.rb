class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.bigint :credit_card_number
      t.string :credit_card_expiration_date
      t.integer :result
      t.references :invoice, foreign_key: true

      t.timestamps
    end
  end
end
