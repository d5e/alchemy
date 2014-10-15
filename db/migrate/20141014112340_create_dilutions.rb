class CreateDilutions < ActiveRecord::Migration
  def change
    create_table :dilutions do |t|
      t.references :substance
      t.string :solvent, :limit => 15
      t.float :concentration
      t.integer :intensity, :limit => 1
    end
  end
end
