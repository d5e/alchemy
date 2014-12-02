class Ingredient < ActiveRecord::Base
  
  belongs_to :blend, touch: true
  belongs_to :substance
  belongs_to :dilution
  
  validates :substance, :dilution, presence: true
  validates :amount, numericality: { greater_than: 0.0 }
  
  validate :substance_match_dilution, :careful_save
  
  delegate :concentration, to: :dilution
  delegate :locked?, to: :blend, allow_nil: true
  
  
  protected
  
  def substance_match_dilution
    errors.add :dilution, :bad if substance && dilution && substance_id != dilution.substance_id
  end
  
  def careful_save
    return true unless blend.locked?
    changes.each do |k,v|
      errors.add k, "cannot change locked record" 
    end
    
  end

end
