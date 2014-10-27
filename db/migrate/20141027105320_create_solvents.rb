class CreateSolvents < ActiveRecord::Migration
  def change
    create_table :solvents do |t|
      t.string :name, limit: 32
      t.string :symbol, limit: 3
      t.string :cas, limit: 12
      t.text :notes
      t.float :price_per_kg

      t.timestamps
    end
  end
end
