module Quantity
  
  attr_accessor :color
  
  def mg?
    self.is_a? MG
  end
  
  def percent?
    self.is_a? Percent
  end
  
  def factor?
    self.is_a? Factor
  end

  def initialize(float)
    @float = float.to_f
  end
  
  def precision
    @precision
  end
  
  def to_s
    @float.to_s
  end
  
  def is_a?(c)
    return true if c == Float
    super
  end
  
  def red!
    @color = :red
    self
  end

  def green!
    @color = :green
    self
  end

  def yellow!
    @color = :yellow
    self
  end

  def blue!
    @color = :blue
    self
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

class Factor
  include Quantity
end


class Object
  def color
    nil
  end
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
  
  def factor?
    nil
  end
  
  def factor!
    Factor.new(self)
  end
  
  def precision
    nil
  end
  
end
