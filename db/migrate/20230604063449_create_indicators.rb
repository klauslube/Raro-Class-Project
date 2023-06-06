class CreateIndicators < ActiveRecord::Migration[7.0]
  def change
    create_table :indicators do |t|
      t.decimal :rate, precision: 10, scale: 6, null: false
      t.string :name, null: false
      
      t.timestamps
    end
  end
end
