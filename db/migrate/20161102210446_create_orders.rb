class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.date :order_date
      t.decimal :vat_percentage
      t.string :aasm_state
      t.string :cancel_reason

      t.timestamps
    end
  end
end
