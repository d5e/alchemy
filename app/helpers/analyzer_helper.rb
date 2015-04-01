module AnalyzerHelper
  
  
  def cnf(value)
    s = nf(value)
    if value.color
      content_tag :span, s, class: "color-#{value.color}"
    else
      s
    end
  end
  
  def nf(value)
    if value.is_a?(Fixnum)
      number_with_precision value, precision: 0
    elsif value.is_a?(Float)
      if value.mg?
        "#{number_with_precision value, precision: 0} mg"
      elsif value.percent?
        "#{number_with_precision value, precision: 2, strip_insignificant_zeros: false} %"
      else
        number_with_precision value, precision: 2, strip_insignificant_zeros: false
      end
    else
      value.to_s
    end
  end
  
  
  
  
  
end
