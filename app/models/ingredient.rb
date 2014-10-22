class Ingredient < ActiveRecord::Base
  
  belongs_to :blend, touch: true
  belongs_to :substance
  belongs_to :dilution
  
  validates :substance, :amount, :dilution, presence: true
  validates :amount, numericality: { greater_than: 0.0 }
  
  delegate :concentration, to: :dilution

end
