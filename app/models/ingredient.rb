class Ingredient < ActiveRecord::Base
  
  belongs_to :blend, touch: true
  belongs_to :substance
  belongs_to :dilution
  
  validates :substance, :dilution, presence: true
  validates :amount, numericality: { greater_than: 0.0 }
  
  validate :substance_match_dilution
  
  delegate :concentration, to: :dilution
  
  
  
  protected
  
  def substance_match_dilution
    errors.add :dilution, :bad if substance && dilution && substance_id != dilution.substance_id
  end

end
