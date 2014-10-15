class Blend < ActiveRecord::Base

  include Searchable

  has_many :ingredients
  has_many :substances, :through => :ingredients
  
  
  accepts_nested_attributes_for :ingredients, allow_destroy: true # reject_if: proc { |attributes| attributes['title'].blank? }

  validates :name, uniqueness: true
  validates :name, :sensory_tags, :notes, :ingredients, :presence => true
  


end

Blend.import
