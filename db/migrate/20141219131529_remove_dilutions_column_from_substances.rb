class RemoveDilutionsColumnFromSubstances < ActiveRecord::Migration
  def change
    remove_column :substances, :dilutions
  end
end
