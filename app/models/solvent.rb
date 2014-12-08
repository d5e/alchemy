class Solvent < ActiveRecord::Base
  
  validate :name, :symbol, presence: true, uniqueness: true
  
  def self.plain_create(name, symbol, cas=nil, price=nil, notes=nil)
    self.create(
      name: name,
      symbol: symbol,
      cas: cas,
      price: price,
      notes: notes
    )
  end
  
end
