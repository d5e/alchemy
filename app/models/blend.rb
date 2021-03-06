class Blend < ActiveRecord::Base

  include Blend::Searchable
  include CasAble
  
  LOCKED_CHANGEABLE = %w(locked sensory_tags notes color)
  
  scope :order_name, -> { order("#{self.table_name}.name ASC") }
  scope :order_updated_at, -> { order("#{self.table_name}.updated_at DESC") }
  scope :order_creation_at, -> { order("#{self.table_name}.creation_at DESC") }#
  scope :visible, lambda { where :hidden => false }
  scope :hidden, lambda { where :hidden => true }
  scope :locked, lambda { where :locked => true }
  
  belongs_to :parent, class_name: "Blend", foreign_key: :parent_id

  has_many :ingredients, dependent: :destroy
  has_many :dilutions, through: :ingredients
  has_many :substances, through: :ingredients
  has_many :children, class_name: "Blend", foreign_key: :parent_id
  
  has_and_belongs_to_many :families
  
  accepts_nested_attributes_for :ingredients, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }

  validates :name, uniqueness: true
  validates :name, :ingredients, :presence => true

  validates_associated  :ingredients
  
  before_destroy :before_destroy
  before_save    :careful_save
  
  def to_s
    name
  end
  
  def exceeding_cat_4?
    exceeders.present?
  end
  
  def exceeders
    @exceeders ||= get_exceeders
  end
  
  def maximum_allowed_concentration
    exceeders
    @exceedance && 1.0 / @exceedance * concentration
  end
  
  def components
    @components ||= get_components
  end
  
  def get_components
    @components = {}
    ingredients.includes(:substance, :dilution).each do |ing|
      tmp_component = Component.new(ing, self)
      add_to_components(tmp_component)
      if tmp_component.substance? && ing.concentration < 1.0
        add_to_components Component.new_for_solvent(ing, self)
      end
    end
    @components.values.sort{|b,a| a.mass <=> b.mass }
  end
  
  def get_exceeders
    m = total_mass.to_f
    @exceedance = 1.0
    exceeders = []
    components.each do |com|
      next if com.molecule.is_a?(Solvent)
      next unless com.molecule.ifra_cat_4_limit
      c = com.mass / m
      if com.molecule.ifra_cat_4_limit < c
        exceeders << com.molecule 
        @exceedance = c / com.molecule.ifra_cat_4_limit
      end
    end
    exceeders
  end

  def composition
    cc = {}
    ingredients.each do |ing|
      # substance
      ing = Ingredient.new(ing.clone_attributes)
      next if ing.dilution && ing.dilution.concentration.to_f == 0
      amount = ing.amount * (ing.dilution.concentration rescue 1.0)
      if cc[ing.substance_id]
        cc[ing.substance_id].amount += amount
      else
        ing.amount = amount
        cc[ing.substance_id] = ing
      end
    end
    
    # TODO SOLVENTS => new calculations needed after new solvent model
    
    ingredients.clone.each do |ing|
      # solvent
      ing = Ingredient.new(ing.clone_attributes)
      next if !ing.dilution || ing.dilution.concentration == 1.0
      s_amount = ing.amount * (1.0 - ing.dilution.concentration)
      key = "solvent_#{ing.dilution.solvent.id rescue rand(1e16) }"
      if cc[key]
        cc[key].amount += s_amount
      else
        ing.amount = s_amount
        cc[key] = ing
      end
    end
    cc
  end
  
  def essence_composition(sort_by=nil)
    cc = {}
    ingredients.each do |ingo|
      ing = Ingredient.new(ingo.clone_attributes)
      next if ingo.dilution && ingo.dilution.concentration.to_f == 0
      amount = ing.amount * (ingo.dilution.concentration rescue 1.0)
      if cc[ing.substance_id]
        cc[ing.substance_id].amount += amount
      else
        ing.amount = amount
        cc[ing.substance_id] = ing
      end
    end
    if sort_by == :vp
      return cc.values.sort{|a,b| a.substance.vp_mmHg_25C.to_f <=> b.substance.vp_mmHg_25C.to_f }
    elsif sort_by == :hashed
      cc
    else
      return cc.values.sort{|a,b| a.amount <=> b.amount }.reverse
    end
  end
  
  def essence_proportions(sort_by=nil)
    cc = {}
    ingredients.each do |ingo|
      next if ingo.solvent_only?
      com = Component.new(ingo)
      if cc[com.cid]
        cc[com.cid].mass += com.mass
      else
        cc[com.cid] = com
      end
    end
    if sort_by == :vp
      return cc.values.sort{|a,b| a.molecule.vp_mmHg_25C.to_f <=> b.molecule.vp_mmHg_25C.to_f }
    elsif sort_by == :hashed
      cc
    else
      return cc.values.sort{|a,b| a.mass <=> b.mass }.reverse
    end
  end
  
  
  def character_proportions
    return {} unless (weight = essence_mass)
    cp = {}
    ingredients.each do |ing|
      # substance
      next if ing.dilution && ing.dilution.concentration.to_f == 0
      percent = ing.amount * (ing.dilution.concentration rescue 1.0) / weight.to_f * 100.0
      name = ing.substance.character || :unknown
      if cp[name]
        cp[name] += percent
      else
        cp[name] = percent
      end
    end
    cp
  end
  
  def raw_price
    return @raw_price if @raw_price 
    price = 0.0
    ingredients.each do |ing|
      next if ing.dilution && ing.dilution.concentration.to_f == 0
      amount = ing.amount * (ing.dilution.concentration rescue 1.0)
      price += amount * ing.substance.price_in_eur_per_100g.to_f * 0.00001 
    end
    @raw_price = price
  end
  
  def price_per_gram(m=100000)
    raw_price * ( m.to_f / total_mass.to_f)
  end
  
  def total_mass
    ingredients.sum(:amount).to_f
  end

  def essence_mass
    c_v = 0
    ingredients.each do |ing|
      c_v += ing.amount * (ing.dilution.concentration rescue 1.0)
    end
    c_v.to_f
  end
  
  # without additional solvents
  def ingredient_weight
    total_mass - additional_solvents_amount
  end
    
  def concentration
    essence_mass / total_mass
  end
  
  def resize!(opts={})
    success = true
    return nil unless total_mass.to_f > 0
    if opts[:factor].to_f > 0
      scale = opts[:factor].to_f
    elsif opts[:mg].to_f > 0
      scale = opts[:mg].to_f / total_mass.to_f
    else
      return nil
    end
    ingredients.each do |ing|
      ing.amount = ing.amount * scale
      success = false unless ing.save
    end
    success
  end

  def additional_solvents_amount
    sum = 0.0
    ingredients.each do |ing|
      sum += ing.amount if ing.dilution && ing.dilution.concentration == 0.0
    end
    sum.to_f
  end
  
  def max_concentration
    essence_mass / (total_mass - additional_solvents_amount)
  end
  
  def adjust!(new_concentration)
    if new_concentration < max_concentration
      new_mass = (essence_mass / new_concentration)
      ing_m = total_mass - additional_solvents_amount
      nasm = new_mass - ing_m
      ratio = (nasm) / additional_solvents_amount
      return total_mass if adjust_solvents_by!(ratio)
    else
      return false
    end
  end
  
  def adjust_solvents_by!(ratio)
#    puts ratio.to_s
    success = true
    ingredients.each do |ing|
      next unless ing.dilution && ing.dilution.concentration == 0.0
      ing.amount *= ratio
      success = false unless ing.save
    end
    success
  end
  
  def unlock_silent
    self.locked = false
    @skip_carefulness = true
  end
  
  protected
  
  def add_to_components(tmp_component)
    key = tmp_component.molecule
    if tmp_component.substance? || tmp_component.molecule.pure?
      if @components[key]
        @components[key].add(tmp_component)
      else
        @components[key] = tmp_component
      end
    else
      # solvents molecular components
      tmp_component.molecule.molecular_composition.each do |mol|
        com = Component.new(mol, self)
        com.mass = tmp_component.mass * mol.virtual_proportion
        add_to_components com
      end
    end
  end
  
  def before_destroy
    return true unless locked?
    errors.add :id, "cannot delete locked record"
    false
  end
  
  def careful_save
    return true if careful_save_allowed
    (changes.keys - ["locked"]).each do |ke|
      errors.add ke, "cannot change locked record"
    end
    false
  end
  
  private
  
  def careful_save_allowed
    return true if @skip_carefulness
    return true unless locked?
    just_locked || locked_changeable
  end
  
  def just_locked
    changes["locked"] == [false, true]
  end

  def locked_changeable
    (changes.keys - LOCKED_CHANGEABLE).blank?
  end
  
end
