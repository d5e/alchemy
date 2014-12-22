class CreateBlendsFamilies < ActiveRecord::Migration
  def change
    create_table :blends_families do |t|
      t.references :blend
      t.references :family
    end
    add_index :blends_families, :blend_id
    add_index :blends_families, :family_id
  end
end
