module CasAble
  
  # A CAS Registry Number, also referred to as CASRN or CAS Number, is a unique numerical identifier assigned by Chemical Abstracts Service (CAS)
  # this concern provides a validation of cas numbers and a getter which can be used in a block to enumerate cas numbers
  # cas numbers shall be stored in a string database field named `cas`, wheras multiple cas numbers might be separated by `,` or `;` or any whitespace character
  
  extend ActiveSupport::Concern

  included do
    validate  :validate_cas_checksum
  end

  def cas
    if block_given? && super.is_a?(String)
      super.gsub(/[;,\s]+/,';').split(';').each do |c|
        yield c
      end
    else
      super
    end
  end

  protected
  
  def validate_cas_checksum
    return unless self.cas
    cas.strip.gsub(/[;,\s]+/,';').split(';').each do |cnr|
      splitted = cnr.split("-")
      if splitted.size != 3
        errors.add :cas, :parts
      else
        if splitted[0].size < 2 || splitted[0].size > 7 ||
           splitted[1].size != 2 || splitted[2].size != 1
          errors.add :cas, :format
        end
      end
      return if errors.include?(:cas)
      cnrs = cnr.gsub(/[^\d]/,'')
      cd = cnrs[cnrs.size - 1,1].to_i
      csum = 0
      (cnrs.size - 1).times do |n|
        csum += cnrs[cnrs.size - 2 - n,1].to_i * (n + 1)
      end
      errors.add :cas, :checksum if csum % 10 != cd
    end
  end
  

end
