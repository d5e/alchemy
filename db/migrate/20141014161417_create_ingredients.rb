class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
      t.references :blend
      t.references :substance
      t.references :dilution
      t.float :amount

      t.timestamps
    end
  end
end
