class Note < ActiveRecord::Base
  
  validates :name, uniqueness: true
  validates :name, :tags, :body, :presence => true
  
  
  
  
end
