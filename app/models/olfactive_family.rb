class OlfactiveFamily < ActiveRecord::Base

  validates_uniqueness_of :name, :case_sensitive => false
  
  has_many :olfactive_families_substances
  
  
  
end
