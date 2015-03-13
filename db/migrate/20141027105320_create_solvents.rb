class CreateSolvents < ActiveRecord::Migration
  def change
    create_table :solvents do |t|
      t.string :name
      t.string :symbol, limit: 3
      t.string :cas, limit: 12
      t.boolean :pure
      t.float :logP
      t.integer :importance, limit: 2, default: 0
      t.text :notes
      t.float :price

      t.timestamps
    end
    
    
    add_column :dilutions, :solvent_id, :integer

    create_table :solvent_ingredients do |t|
      t.integer :solvent_id
      t.integer :ingredient_id
      t.float :amount
    end
    
  end
  
end
