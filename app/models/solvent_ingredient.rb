class SolventIngredient < ActiveRecord::Base
  
  belongs_to :solvent, inverse_of: :solvent_ingredients
  belongs_to :ingredient, class_name: "Solvent"
  
  has_many :blends, through: :dilutions
  has_many :dilutions, through: :solvents
  
  validates :solvent, :ingredient, presence: true
  validates :amount, numericality: { greater_than: 0.0 }
  
  validate :careful_save
  

  def virtual_solvent(fraction=1.0, stop_at_symbols=false)
    if stop_at_symbols
      ingredient.symbolic_composition(fraction * proportion)
    else
      ingredient.molecular_composition(fraction * proportion)
    end
  end

  def proportion
    amount / solvent.total_composition_mass.to_f
  end
  
  def percent
    proportion * 100.0
  end
  
  
  protected
  
  def careful_save
    return true unless solvent
    return true unless solvent.locked?
    changes.each do |k,v|
      errors.add k, "cannot change solvent ingredient contained in locked blend" 
    end
  end
  
end
