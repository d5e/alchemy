class Array
  
  def normalize!(mt=nil)
    validate_components!
    mt ||= components_total_mass
    each{ |c| c.normalize! mt }
    self
  end
  
  def validate_components!
    raise_if_foreign
    raise_if_mass_blank
    true
  end
  
  protected

  def raise_if_foreign
    fc = map(&:class).uniq - [Component]
    return if fc.blank?
    raise "only component arrays can be normalized, but found #{fc.map(&:to_s).to_sentence}"
  end
  
  def raise_if_mass_blank
    each do |c|
      raise "component #{c.inspect} has nil mass" unless c.mass
    end
  end
  
  def components_total_mass
    map(&:mass).sum
  end
  
end



class NilClass
  
  def dup
    nil
  end
  
end