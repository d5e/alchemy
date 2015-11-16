class Solvent < ActiveRecord::Base

  include CasAble

  attr_accessor :virtual_proportion, :existing_dilution, :virtual_amount
  
  attr_writer :existing_dilution_id, :existing_dilution_amount

  serialize :composition, Hash
  
  has_many :dilutions
  has_many :solvents
  has_many :substances, through: :dilutions
  has_many :solvent_ingredients, inverse_of: :solvent
  has_many :contained_in_solvents, class_name: "SolventIngredient", foreign_key: :ingredient_id

  scope :by_name, lambda { order("name ASC") }
  scope :by_importance, lambda { order("importance DESC") }
  scope :pure, lambda { where pure: true }
  scope :basics, lambda { where "importance > -5 " }
  
  before_save :check_pureness, :merge_duplicates
  
  validates :name, presence: true, uniqueness: true
  validates :symbol, uniqueness: true, allow_blank: true
  validate :validate_symbol_presence_if_pure
  
  accepts_nested_attributes_for :solvent_ingredients, allow_destroy: true
  validates_associated :solvent_ingredients

  def existing_dilution_id
    return @existing_dilution_id if @existing_dilution_id
    existing_dilution.id if existing_dilution
  end
  
  def existing_dilution_amount
    @existing_dilution_amount.to_f
  end
  
  def total_composition_mass
    return 1.0 if pure?
    if solvent_ingredients.all?(&:persisted?)
      solvent_ingredients.pluck("sum(amount) as sum").first
    else
      solvent_ingredients.to_a.sum(&:amount)
    end
  end

  def members
    return [self] if pure?
    ms = []
    solvent_ingredients.each do |sing|
      ms += sing.ingredient.members
    end
    ms.uniq
  end

  def locked?
    return false unless persisted?
    solvent_ids = Blend.locked.map(&:dilutions).flatten.map(&:solvent_id).uniq
    svs = Solvent.where(id: solvent_ids)
    svs2 = []
    svs.each do |sv|
      svs2 += sv.members
    end
    locked_solvent_ids = (svs.map(&:id) + svs2.map(&:id)).uniq
    self.id.in? locked_solvent_ids
  end
  
  def pure_live?
    solvent_ingredients.blank?
  end

  def check_pureness
    self.pure = pure_live?
    true
  end
  
  def substance_count
    return 1 if pure?
    c = 0
    composition.each do |proportion, primary_id|
      c += Solvent.find(primary_id).substance_count
    end
    c
  end
  
  def ingredients_molecular?
    return nil if pure?
    solvent_ingredients.all?{ |sing| sing.ingredient.pure? }
  end
  
  def molecular_composition(fraction=1.0)
    if pure?
      @virtual_proportion = fraction
      return [self]
    else
      merge_virtual_amounts solvent_ingredients.map{ |sing| sing.virtual_solvent(fraction) }.flatten
    end
  end

  def symbolic_composition(fraction=1.0)
    if self.symbol.present?
      @virtual_proportion = fraction
      return [self]
    else
      merge_virtual_amounts solvent_ingredients.map{ |sing| sing.virtual_solvent(fraction, true) }.flatten
    end
  end

  def to_s
    name
  end
  
  def generate_name
    if pure?
      return false
    else
      nc = []
      symbolic_composition.each do |sv|
        nc << "#{sv.virtual_proportion.round(3 - Math.log10(sv.virtual_proportion).round)} #{sv.symbol}"
      end
      self.name = nc.join(" ")
    end
  end
  
  protected
  
  def merge_duplicates
    sing = {}
    solvent_ingredients.each do |ing|
      if sing[ing.ingredient.id]
        sing[ing.ingredient.id].amount += ing.amount
        solvent_ingredients.delete ing
      else
        sing[ing.ingredient.id] = ing
      end
    end
  end
  
  def merge_virtual_amounts(svs=[])
    by_primary = {}
    svs.each do |sv|
      if by_primary[sv.id]
        by_primary[sv.id].virtual_proportion += sv.virtual_proportion
      else
        by_primary[sv.id] = sv
      end
    end
    by_primary.values
  end

  def validate_symbol_presence_if_pure
    errors.add :symbol, :blank if self.symbol.blank? && pure_live?
  end

end
