class AddLockToBlends < ActiveRecord::Migration
  def change
    add_column :blends, :locked, :boolean, default: false
    add_column :blends, :hidden, :boolean, default: false
    add_column :blends, :parent_id, :integer
  end
end
