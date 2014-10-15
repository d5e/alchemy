class CreateSubstances < ActiveRecord::Migration
  def change
    create_table :substances do |t|
      t.string :name
      t.string :cas
      t.float :ifra_cat_4_limit
      t.text :alt_names
      t.text :sensory_tags
      t.text :notes
      t.text :dilutions

      t.timestamps
    end
  end
end
