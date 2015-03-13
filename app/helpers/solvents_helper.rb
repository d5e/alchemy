module SolventsHelper
  
  def solvent_link(solvent_or_dilution)
    if solvent_or_dilution.is_a?(Dilution)
      solvent = solvent_or_dilution.solvent
      dilution = solvent_or_dilution
      if dilution.concentration == 0.0
        text = dilution.solvent
      elsif dilution.concentration == 1.0
        "Pure"
      else
        text = "#{number_with_precision dilution.concentration * 100} % in #{dilution.solvent}"
      end
      link_to text, solvent_path(dilution.solvent, dilution_id: dilution.id) rescue "dilution_#{dilution.id}"
    else
      link_to solvent_or_dilution, solvent_or_dilution
    end
  end
  
end
