class CreateOlfactiveFamiliesSubstances < ActiveRecord::Migration
  def change
    create_table :olfactive_families_substances do |t|
      t.integer :substance_id
      t.integer :olfactive_family_id
      t.column :affinity, "TINYINT UNSIGNED"

      t.timestamps
    end
  end
end
