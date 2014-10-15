class Substance < ActiveRecord::Base
  
 
  include Substance::Searchable
  
  IFRA_LIMIT_CONCENTRATIONS = [ 0.1, 0.05, 0.02, 0.01, 0.005, 0.004, 0.002, 0.001, 0.0005, 0.0002, 0.00001 ]
  
  default_scope { order("#{self.table_name}.name ASC") }

  has_many :dilutions
    
  accepts_nested_attributes_for :dilutions, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }
  
  validates :name, :cas, uniqueness: true, allow_blank: true
  validates :name, :sensory_tags, :presence => true

end


Substance.import

