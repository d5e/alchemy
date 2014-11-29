class Blend < ActiveRecord::Base

  include Searchable
  
  scope :order_updated_at, -> { order("#{self.table_name}.updated_at DESC") }
  scope :order_creation_at, -> { order("#{self.table_name}.creation_at DESC") }

  has_many :ingredients, dependent: :destroy
  has_many :substances, through: :ingredients
  has_many :children, class_name: "Blend", foreign_key: :parent_id
  
  accepts_nested_attributes_for :ingredients, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }

  validates :name, uniqueness: true
  validates :name, :ingredients, :presence => true

  validates_associated  :ingredients

  def to_s
    name
  end

  def composition
    cc = {}
    ingredients.each do |ing|
      # substance
      ing = Ingredient.new(ing.clone_attributes)
      next if ing.dilution && ing.dilution.concentration.to_f == 0
      amount = ing.amount * (ing.dilution.concentration rescue 1.0)
      if cc[ing.id]
        cc[ing.id].amount += amount
      else
        ing.amount = amount
        cc[ing.id] = ing
      end
    end
    ingredients.clone.each do |ing|
      # solvent
      ing = Ingredient.new(ing.clone_attributes)
      next if !ing.dilution || ing.dilution.concentration == 1.0
      s_amount = ing.amount * (1.0 - ing.dilution.concentration)
      key = ing.dilution.solvent.to_sym
      if cc[key]
        cc[key].amount += s_amount
      else
        ing.amount = s_amount
        cc[key] = ing
      end
    end
    cc
  end
  
  def character_proportions
    return {} unless (weight = essence_weight)
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
    raw_price * ( m.to_f / total_weight.to_f)
  end
  
  def total_weight
    ingredients.sum(:amount).to_f
  end

  def essence_weight
    c_v = 0
    ingredients.each do |ing|
      c_v += ing.amount * (ing.dilution.concentration rescue 1.0)
    end
    c_v.to_f
  end
  
  # without additional solvents
  def ingredient_weight
    total_weight - additional_solvents_amount
  end
    
  def concentration
    essence_weight / total_weight
  end
  
  def resize!(new_mass)
    success = true
    return nil unless total_weight.to_f > 0
    scale = new_mass.to_f / total_weight.to_f
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
    essence_weight / (total_weight - additional_solvents_amount)
  end
  
  def adjust!(new_concentration)
    if new_concentration < max_concentration
      new_mass = (essence_weight / new_concentration)
      ing_m = total_weight - additional_solvents_amount
      nasm = new_mass - ing_m
      ratio = (nasm) / additional_solvents_amount
      return total_weight if adjust_solvents_by!(ratio)
    else
      return false
    end
  end
  
  def adjust_solvents_by!(ratio)
    puts ratio.to_s
    success = true
    ingredients.each do |ing|
      next unless ing.dilution && ing.dilution.concentration == 0.0
      ing.amount *= ratio
      success = false unless ing.save
    end
    success
  end
  
end
