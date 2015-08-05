class OlfactiveFamiliesSubstances < ActiveRecord::Base
  
  belongs_to :olfactive_family
  belongs_to :substance

  scope :order_by_affinity, lambda { order("#{self.table_name}.affinity DESC") }
  default_scope lambda { order_by_affinity }

  validates_presence_of :olfactive_family_id, :substance_id, :affinity
  validates_numericality_of :olfactive_family_id, :substance_id, :affinity

end
