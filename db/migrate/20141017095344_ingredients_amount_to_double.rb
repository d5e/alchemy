class IngredientsAmountToDouble < ActiveRecord::Migration
  def change
    change_column :ingredients, :amount, :float, :limit => 52
  end
end
