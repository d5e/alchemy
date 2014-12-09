class Substance < ActiveRecord::Base
 
  include Substance::Searchable
  
  IFRA_LIMIT_CONCENTRATIONS = [ 0.1, 0.05, 0.02, 0.01, 0.005, 0.004, 0.002, 0.001, 0.0005, 0.0002, 0.00001 ]
  
  CURRENCIES = {
    :GBP => 0.79626,
    :EUR => 1,
    :USD => 1.27444
  }
  
  scope :order_alphabetical, lambda { order("#{self.table_name}.name ASC") }
  scope :order_character, -> { unscoped.order("#{self.table_name}.character ASC").order("#{self.table_name}.name ASC") }
  default_scope lambda { order_alphabetical }
  scope :visible, lambda { where("1=1")}
  scope :hidden, lambda { where("0=1")}

  has_many :dilutions
  has_many :ingredients, dependent: :restrict_with_error
  has_many :blends, through: :ingredients
    
  accepts_nested_attributes_for :dilutions, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }
  
  validates :name, :cas, uniqueness: true, allow_blank: true
  validates :name, :sensory_tags, :presence => true
  
  validates :ifra_cat_4_limit, numericality: { greater_than_or_equal_to: 0, smaller_than: 1 }, allow_blank: true
  
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
  
  def cas
    if block_given? && super.is_a?(String)
      super.gsub(/[,\s]+/,' ').split(' ').each do |c|
        yield c
      end
    else
      super
    end
  end

end
