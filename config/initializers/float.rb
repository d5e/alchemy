class Float
  
  def percent!
    @type = :percent
    self
  end
  
  def percent?
    @type == :percent
  end
  
  def mg!
    @type = :mg
    self
  end
  
  def mg?
    @type == :mg
  end
  
  def type
    @type.to_sym if @type
  end
  
end