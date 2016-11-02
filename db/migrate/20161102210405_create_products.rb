class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :net_price, precision:5, scale:3

      t.timestamps
    end
  end
end
