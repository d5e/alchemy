class Solvent < ActiveRecord::Base

  attr_accessor :virtual_proportion, :existing_dilution, :existing_dilution_amount, :virtual_amount, :solvent_id
  
  attr_writer :existing_dilution_id

  serialize :composition, Hash
  
  has_many :dilutions
  has_many :solvents
  
  has_many :substances, through: :dilutions

  scope :by_name, lambda { order("name ASC") }
  scope :by_importance, lambda { order("importance DESC") }
  
  validates :name, presence: true, uniqueness: true
  validates :symbol, uniqueness: true, allow_blank: true
  
  accepts_nested_attributes_for :solvents, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }
  
  def composition_attributes=(s)
    new_solvent_found = false
    other_solvent_found = false
    s.each do |tid, attribs|
      # test if new solvent is necessary
      new_solvent_found = true if attribs['_destroy'] == "false"
      other_solvent_found = true if attribs['solvent_id'] != self.id 
    end
    
    if persisted? && !other_solvent_found
      errors.add :solvents, "solvent mix empty"
    elsif new_solvent_found
      s.each do |tid, attribs|
        # make compostion
      end
    else
      # do nothing
    end
    
    if existing_dilution_id.present?
      # create new dilution for substance with newly created solvent
    end
    
    Rails.logger.info '#### CAs #############'
    Rails.logger.info s.inspect
  end

  def composition_attributes
    {}
  end

  def existing_dilution_id
    return @existing_dilution_id if @existing_dilution_id
    existing_dilution.id if existing_dilution
  end



  
  def pure?
    composition.blank?
  end
  
  def substance_count
    return 1 if pure?
    c = 0
    composition.each do |proportion, primary_id|
      c += Solvent.find(primary_id).substance_count
    end
    c
  end
  
  def proportional_composition(proportion=1.0)
    if pure?
      self.virtual_proportion = proportion
      return { id => self }
    end
    cs = {}
    composition.each do |sub_prop, primary_id|
      Solvent.find(primary_id).proportional_composition(proportion * sub_prop).each do |pid, solvent|
        if cs[pid]
          cs[pid].virtual_proportion += proportion * sub_prop
        else
           cs[pid] = solvent
        end
      end
    end
    cs
  end
  
  def to_s
    name
  end
  
  protected
  
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


# 
# t.string :name, limit: 32
# t.string :symbol, limit: 3
# t.string :cas, limit: 12
# t.float :logP
# 
# t.integer :composite_id
# t.float :purity, default: 1
# 
# t.text :notes
# t.float :price_per_kg
