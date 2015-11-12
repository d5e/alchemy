module SolventsHelper
  
  def solvent_link(solvent_or_dilution)
    if solvent_or_dilution.is_a?(Dilution)
      solvent = solvent_or_dilution.solvent
      dilution = solvent_or_dilution
      if dilution.concentration == 0.0
        text = dilution.solvent
      elsif dilution.concentration == 1.0
        return "Pure"
      else
        text = "#{number_with_precision dilution.concentration * 100} % in #{dilution.solvent}"
      end
      link_to text, solvent_path(dilution.solvent, dilution_id: dilution.id) rescue "dilution_#{dilution.id}"
    else
      link_to solvent_or_dilution, solvent_or_dilution
    end
  end
  
  def basic_solvents_and_current_for_dropdown(dilution=nil)
    solvents = Solvent.basics.to_a
    solvents.unshift(dilution.solvent) if dilution && dilution.solvent && !dilution.solvent.in?(solvents)
    solvents.map{ |sv| [ sv.name, sv.id ] }
  end
  
end
