class Blend < ActiveRecord::Base

  include Searchable

  has_many :ingredients
  has_many :substances, :through => :ingredients
  
  
  accepts_nested_attributes_for :ingredients, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }

  validates :name, uniqueness: true
  validates :name, :sensory_tags, :notes, :ingredients, :presence => true
  


  def composition
    cc = {}
    ingredients.each do |ing|
      # ing
      amount = ing.amount * (ing.dilution.concentration rescue 1.0)
      if cc[ing.id]
        cc[ing.id].amount += amount
      else
        ing.amount = amount
        cc[ing.id] = ing
      end
    end
    ingredients.each do |ing|
      # solvent
      next unless ing.dilution
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

end

Blend.import
