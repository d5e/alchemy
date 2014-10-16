class Blend < ActiveRecord::Base

  include Searchable

  has_many :ingredients
  has_many :substances, :through => :ingredients
  
  accepts_nested_attributes_for :ingredients, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }

  validates :name, uniqueness: true
  validates :name, :sensory_tags, :notes, :ingredients, :presence => true
  

  def to_s
    name
  end

  def composition
    cc = {}
    total_weight = 0.0
    ingredients.clone.each do |ing|
      # ing
      next if ing.dilution && ing.dilution.concentration.to_f == 0
      amount = ing.amount * (ing.dilution.concentration rescue 1.0)
      total_weight += amount
      if cc[ing.id]
        cc[ing.id].amount += amount
      else
        ing.amount = amount
        cc[ing.id] = ing
      end
    end
    ingredients.clone.each do |ing|
      # solvent
      next if !ing.dilution || ing.dilution.concentration == 1.0
      s_amount = ing.amount * (1.0 - ing.dilution.concentration)
      total_weight += s_amount
      key = ing.dilution.solvent.to_sym
      if cc[key]
        cc[key].amount += s_amount
      else
        ing.amount = s_amount
        cc[key] = ing
      end
    end
    @total_weight = total_weight
    cc
  end
  
  def total_weight
    return @total_weight if @total_weight
    composition
    @total_weight
  end

end

Blend.import
