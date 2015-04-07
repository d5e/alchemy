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
        "#{number_with_precision value, precision: prec(value, 3), strip_insignificant_zeros: true} mg"
      elsif value.percent?
        "#{number_with_precision value * 100, precision: prec(value, 1), strip_insignificant_zeros: true} %"
      elsif value.factor?
        "#{number_with_precision value, precision: prec(value, 3), strip_insignificant_zeros: true} x"
      else
        number_with_precision value, precision: prec(value, 3), strip_insignificant_zeros: true
      end
    else
      value.to_s
    end
  end
  
end
