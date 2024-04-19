class CreateCoupons < ActiveRecord::Migration[7.1]
  def change
    create_table :coupons do |t|
      t.string :name, null: false
      t.string :code, null: false, index: { unique: true }
      t.integer :discount_type, null: false
      t.integer :discount, null: false
      t.integer :status, default: 0
      t.references :merchant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
