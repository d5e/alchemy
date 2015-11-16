class Component
  
  include ActiveModel::Model
  
  attr_accessor :mass, :molecule, :color
  
  def self.new_for_solvent(ingredient, blend=nil)
    if ingredient.is_a?(Ingredient)
      self.new ingredient, blend, true
    end
  end
  
  def initialize(arg, blend=nil, extract_solvent=false)
    if arg.is_a?(Solvent)
      @mass = 0.0
      @molecule = arg
    elsif arg.is_a?(Substance)
      @mass = 0.0
      @molecule = arg
    elsif arg.is_a?(Component)
      super arg.attributes
    elsif arg.is_a?(Ingredient)
      if arg.solvent_only? || extract_solvent
        @mass = arg.solvent_mass
        @molecule = arg.solvent
      else
        @mass = arg.substance_mass
        @molecule = arg.substance
      end
    else
      super(arg)
    end
    normalize!(blend.total_mass) if blend
    raise "#{self.inspect} : #{arg.inspect}" unless mass
  end
  
  def attributes
    {
      mass: mass,
      molecule: molecule
    }
  end
  
  def dup
    Component.new attributes
  end
  
  def add(ing)
    return add_component(ing) if ing.is_a?(Component)
    raise "tried to add #{ing.class.name} to component" unless ing.is_a?(Ingredient)
    if substance?
      raise "tried to change components immutable substance" if molecule != ing.substance
      @mass += ing.substance_mass
    elsif solvent?
      raise "tried to change components immutable solvent"   if molecule != ing.solvent
      @mass += ing.solvent_mass
    end
  end
  
  def add_component(c2)
    raise "tried to change components immutable molecule" if molecule != c2.molecule
    @mass += c2.mass
  end
  
  def cid
    return rand(1e24).to_s(36) unless molecule
    "#{molecule.class.to_s[0,3]}_#{molecule.id}"
  end
  
  def solvent?
    molecule.is_a?(Solvent)
  end
  
  def substance?
    molecule.is_a?(Substance)
  end
  
  def zero?
    mass.to_f == 0.0
  end
  
  def normalize!(total_mass)
    @total_mass = total_mass.to_f
  end
  
  def proportion
    if @mass.to_f == 0.0
      cc = 0.0.percent!
      cc.blue!
      return cc
    end
    return nil unless @mass && @total_mass
    f = (@mass / @total_mass).percent!
    return f unless color
    f.color = color
    f
  end
  
  def self.substances_from_blend_by_substance_id(blend)
    self.substances_from_blends_by_substance_id [blend]
  end
  
  def self.substances_from_blends_by_substance_id(blends)
    raise "argument has to be an array of blends" unless blends.is_a?(Array) && blends.map(&:class).uniq == [Blend]
    cc = {}
    blends.each do |b|
      b.ingredients.each do |ing|
        next if ing.solvent_only?
        k = ing.substance.id 
        if cc[k]
          cc[k].add ing
        else
          cc[k] = Component.new(ing)
        end
      end
    end
    cc.values.normalize!
    cc
  end
  
end





           # TODO =>     extend array to normalize an array of components     Array.normalize!
