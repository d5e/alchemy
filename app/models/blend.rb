class Blend < ActiveRecord::Base

  include Searchable

  has_many :ingredients, dependent: :destroy
  has_many :substances, through: :ingredients
  
  accepts_nested_attributes_for :ingredients, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }

  validates :name, uniqueness: true
  validates :name, :sensory_tags, :notes, :ingredients, :presence => true

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
      name = ing.substance.character || :none
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
    ingredients.sum(:amount)
  end

  def essence_weight
    c_v = 0
    ingredients.each do |ing|
      c_v += ing.amount * (ing.dilution.concentration rescue 1.0)
    end
    c_v
  end
    
  def concentration
    essence_weight / total_weight
  end
  
  def concentration_human
    if concentration > 0.39
      "Huiles essentielles"
    elsif concentration > 0.197
      "Perfume extraits"
    elsif concentration > 0.1145
      "Eau de Parfum"
    elsif concentration > 0.068
      "Eau de Toilette"
    elsif concentration > 0.039
      "Eau de Cologne"
    elsif concentration > 0.0149
      "Eau Légère"
    elsif concentration > 0.5
      "Eau de solide"
    elsif concentration > 0.0
      "traces"
    else
      "inv"
    end
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
  
end

Blend.import force: true
