class AddCharacterToSubstance < ActiveRecord::Migration
  def change
    add_column :substances, :character, :string, limit: 20
    add_column :blends, :color, :string, limit: 8
  end
end
