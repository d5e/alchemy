class Substance < ActiveRecord::Base
 
  include Substance::Searchable
  include CasAble
  
  IFRA_LIMIT_CONCENTRATIONS = [ 0.317, 0.214, 0.13, 0.08, 0.107, 0.053, 0.032, 0.0267, 0.025, 0.019, 0.016, 0.014, 0.0104, 0.01, 0.005, 0.004, 0.002, 0.001, 0.0002 ]
  TENACITY_CATs = %w(base base-heart heart heart-top top)
  
  CURRENCIES = {
    :GBP => 0.71,
    :EUR => 1,
    :USD => 1.06
  }
  
  scope :order_alphabetical, lambda { order("#{self.table_name}.name ASC") }
  scope :order_character, -> { unscoped.order("#{self.table_name}.character ASC").order("#{self.table_name}.name ASC") }
  scope :order_vp, -> { unscoped.order("#{self.table_name}.vp_mmHg_25C ASC").order("#{self.table_name}.character ASC").order("#{self.table_name}.name ASC") }
  default_scope lambda { order_alphabetical }
  scope :visible, lambda { where("1=1")}
  scope :hidden, lambda { where("0=1")}

  has_many :dilutions
  has_many :ingredients, dependent: :restrict_with_error
  has_many :blends, through: :ingredients
  has_many :olfactive_families_substances
    
  accepts_nested_attributes_for :dilutions, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }
  
  validates :name, :cas, uniqueness: true, allow_blank: true
  validates :name, :sensory_tags, :presence => true
  validates :ifra_cat_4_limit, numericality: { greater_than_or_equal_to: 0, less_than: 1 }, allow_blank: true
  
  validates_associated :dilutions
  
  
  def price_in_eur_per_100g
    price_in_currency_per_100g / CURRENCIES[price_currency.to_sym] rescue nil
  end
  
  def price_in_currency_per_100g
    price_per_quantity * (100.0 / quantity_in_gram_of_raw_material ) rescue nil
  end
  
  def to_s
    name
  end
  
  def alt_names
    if block_given?
      self[:alt_names].split(';').each{ |n| yield n.strip }
    else
      self[:alt_names]
    end
  end
  
  protected

end
