class AddNotesToSubstances < ActiveRecord::Migration
  def change
    add_column :substances, :notes_alt_1, :text
    add_column :substances, :notes_alt_2, :text
  end
end
