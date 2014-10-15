class Ingredient < ActiveRecord::Base
  
  belongs_to :blend
  belongs_to :substance

  
end
