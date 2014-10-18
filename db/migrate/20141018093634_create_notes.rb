class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :name
      t.text :tags
      t.text :body
      t.text :links

      t.timestamps
    end
  end
end
