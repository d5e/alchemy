class AddPropertiesToSubstances < ActiveRecord::Migration
  def change
    add_column :substances, :vp_mmHg_25C, :float
    add_column :substances, :bpC_760mmHg, :float
    add_column :substances, :tenacity_h, :integer, limit: 2
    add_column :ingredients, :highlighted, :boolean
  end
end
