class Ingredient < ActiveRecord::Base
  
  belongs_to :blend
  belongs_to :substance
  belongs_to :dilution
  
  validates :blend, :substance, :amount, presence: true
  validates :amount, numericality: { greater_than: 0.0 }

end
