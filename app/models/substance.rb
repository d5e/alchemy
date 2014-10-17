class Substance < ActiveRecord::Base
 
  include Substance::Searchable
  
  IFRA_LIMIT_CONCENTRATIONS = [ 0.1, 0.05, 0.02, 0.01, 0.005, 0.004, 0.002, 0.001, 0.0005, 0.0002, 0.00001 ]
  
  CURRENCIES = {
    :GBP => 0.79626,
    :EUR => 1,
    :USD => 1.27444
  }
  
  default_scope { order("#{self.table_name}.name ASC") }

  has_many :dilutions
  has_many :ingredients, dependent: :restrict_with_error
  has_many :blends, through: :ingredients
    
  accepts_nested_attributes_for :dilutions, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }
  
  validates :name, :cas, uniqueness: true, allow_blank: true
  validates :name, :sensory_tags, :presence => true
  
  
  
  def price_in_eur_per_100g
    price_in_currency_per_100g / CURRENCIES[price_currency.to_sym] rescue nil
  end
  
  def price_in_currency_per_100g
    price_per_quantity * (100.0 / quantity_in_gram_of_raw_material ) rescue nil
  end
  
  def to_s
    name
  end

end


Substance.import force: true

