class AddPriceToSubstance < ActiveRecord::Migration
  def change
    add_column :substances, :price_per_quantity, :float
    add_column :substances, :price_currency, :string, :limit => 3
    add_column :substances, :quantity_in_gram_of_raw_material, :float
  end
end
