class CreateFamilies < ActiveRecord::Migration
  def change
    create_table :families do |t|
      t.integer :parent_id
      t.string  :name
      t.string  :color, limit: 8
      t.text    :tags
      t.text    :notes
      t.timestamps
    end
  end
end
