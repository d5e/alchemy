class CreateBlends < ActiveRecord::Migration
  def change
    create_table :blends do |t|
      t.string :name
      t.text :sensory_tags
      t.text :notes

      t.date :creation_at

      t.timestamps
    end
  end
end
