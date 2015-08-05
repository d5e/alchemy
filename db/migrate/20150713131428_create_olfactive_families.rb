class CreateOlfactiveFamilies < ActiveRecord::Migration

  OLFACTIVE_FAMILIES = {
    'Aldehylic' => [ '99eee7', '6de7dd','c5f5f1' ],
    'Amber' => [ 'b7ab98', 'a2937a','ccc3b6' ],
    'Animal' => [ '706361', '554b49','8b7b79' ],
    'Aromatic' => [ '6b7643', '4d5531','889755' ],
    'Bergamot' => [ '93c64b', '79a935','aad272' ],
    'Balsamic' => [ 'e8ac88', 'e08e5d','f0cab3' ],
    'Citrus' => [ 'efe761', 'eae033','f4ee8f' ],
    'Earthy' => [ '676437', '464425','888449' ],
    'Floral' => [ 'da5a72', 'd1304e','e38496' ],
    'Fruity' => [ 'e68064', 'df5c38','eda490' ],
    'Galbanum' => [ 'dacf74', 'cfc14c','e5dd9c' ],
    'Gourmand' => [ 'c7a83b', 'a1882e','d2ba63' ],
    'Green' => [ '7a9b4c', '5f793b','93b466' ],
    'Herbal' => [ 'acc652', '92ac39','bed378' ],
    'Jasmin' => [ 'c0e3f7', '93cff1','edf7fd' ],
    'Lactonic' => [ 'edd4d7', 'deb0b6','fcf8f8' ],
    'Marine' => [ '61afd7', '389acd','8ac4e1' ],
    'Musk' => [ '936445', '704c35','b17c5a' ],
    'Orange' => [ 'f7b556', 'f5a025','f9ca87' ],
    'Ozone' => [ '71def5', '41d3f2','a1e9f8' ],
    'Powdery' => [ 'dd7fcf', 'd257c0','e8a7de' ],
    'Rose' => [ 'f180a5', 'ec5284','f6aec6' ],
    'Sandalwood' => [ 'd1816b', 'c56044','dda292' ],
    'Spicy' => [ 'a24529', '79341f','cb5633' ],
    'Sweet' => [ 'f5a694', 'f17f65','f9cdc3' ],
    'Woody' => [ '66553d', '463a2a','867050' ]
  }
  
  
  def up
    create_table :olfactive_families do |t|
      t.string :name
      t.integer :parent_id
      t.column :color, "char(8)"
      t.column :color_light, "char(8)"
      t.column :color_dark, "char(8)"
      t.float :share

      t.text :description

      t.timestamps
    end
    
    seed
  end
  
  def down
    drop_table :olfactive_families
  end
  
  def seed
    OlfactiveFamily.reset_column_information
    
    OLFACTIVE_FAMILIES.each do |name, colors|
      OlfactiveFamily.create name: name, color: colors.shift, color_light: colors.shift, color_dark: colors.shift
    end

  end


end
