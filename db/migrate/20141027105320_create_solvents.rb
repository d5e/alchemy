class CreateSolvents < ActiveRecord::Migration
  def up
    create_table :solvents do |t|
      t.string :name, limit: 32
      t.string :symbol, limit: 3
      t.string :cas, limit: 12
      t.float :logP
      
      t.integer :importance, limit: 2, default: 0

      t.text  :composition

      t.text :notes
      t.float :price

      t.timestamps
    end
    
    
    add_column :dilutions, :solvent_id, :integer
    
    
    
  end
  
  def down
    drop_table :solvents
  end
  
end
