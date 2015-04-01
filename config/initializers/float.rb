module Quantity
  
  def mg?
    self.is_a? MG
  end
  
  def percent?
    self.is_a? Percent
  end

  def initialize(float)
    @float = float.to_f
  end
  
  def to_s
    @float.to_s
  end
  
  def is_a?(c)
    return true if c == Float
    super
  end
  
  protected
  
  def method_missing(*args)
    @float.send *args
  end
  
end


class Percent
  include Quantity
end

class MG
  include Quantity
end


class Float
  
  def percent!
    Percent.new(self)
  end
  
  def percent?
    nil
  end
  
  def mg!
    MG.new(self)
  end
  
  def mg?
    nil
  end
  
end
