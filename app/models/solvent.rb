class Solvent < ActiveRecord::Base

  attr_accessor :virtual_proportion, :existing_dilution, :existing_dilution_amount, :virtual_amount
  
  attr_writer :existing_dilution_id

  serialize :composition, Hash
  
  has_many :dilutions
  has_many :solvents
  has_many :substances, through: :dilutions
  has_many :solvent_ingredients, inverse_of: :solvent
  has_many :contained_in_solvents, class_name: "SolventIngredient", foreign_key: :ingredient_id

  scope :by_name, lambda { order("name ASC") }
  scope :by_importance, lambda { order("importance DESC") }
  scope :pure, lambda { where pure: true }
  
  before_save :check_pureness
  
  validates :name, presence: true, uniqueness: true
  validates :symbol, uniqueness: true, allow_blank: true
  
  accepts_nested_attributes_for :solvent_ingredients, allow_destroy: true
  validates_associated :solvent_ingredients

  def existing_dilution_id
    return @existing_dilution_id if @existing_dilution_id
    existing_dilution.id if existing_dilution
  end
  
  def total_composition_mass
    return 1.0 if pure?
    solvent_ingredients.pluck("sum(amount) as sum").first
  end

  def members
    return [self] if pure?
    ms = []
    solvent_ingredients.each do |sing|
      ms += sing.ingredient.members
    end
    ms
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

  def check_pureness
    self.pure = solvent_ingredients.blank?
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

  def to_s
    name
  end
  
  protected
  
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
  
  def validate_cas_checksum
    cas.gsub(/[;,\s]+/,' ').split(' ').each do |cnr|
      splitted = cnr.split("-")
      if splitted.size != 3
        errors.add :cas, :parts
      else
        if splitted[0].size < 2 || splitted[0].size > 7 ||
           splitted[1].size != 2 || splitted[2].size != 1
          errors.add :cas, :format
        end
      end
      cnrs = cnr.gsub("-",'')
      cd = cnrs.last
      csum = 0
      cnrs[size].times do |n|
        csum += cnrs[n-1].to_i * n
      end
      errors.add :cas, :checksum if csum % 10 != cd
    end
  end
  
end
