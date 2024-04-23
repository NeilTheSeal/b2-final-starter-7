class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :discount_type, null: false
      t.integer :discount, null: false
      t.integer :status, default: 1
      t.references :merchant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
