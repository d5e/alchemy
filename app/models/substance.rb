class Substance < ActiveRecord::Base
 
  include Substance::Searchable
  
  IFRA_LIMIT_CONCENTRATIONS = [ 0.317, 0.214, 0.13, 0.08, 0.107, 0.053, 0.032, 0.0267, 0.025, 0.019, 0.016, 0.014, 0.0104, 0.01, 0.005, 0.004, 0.002, 0.001, 0.0002 ]
  
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
    
  accepts_nested_attributes_for :dilutions, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }
  
  validates :name, :cas, uniqueness: true, allow_blank: true
  validates :name, :sensory_tags, :presence => true
  validates :ifra_cat_4_limit, numericality: { greater_than_or_equal_to: 0, less_than: 1 }, allow_blank: true
  validate  :validate_cas_checksum
  
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
  
  protected
  
  def validate_cas_checksum
    self.cas.strip!
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
