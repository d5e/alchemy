class SolventsController < InheritedResources::Base
      
  before_filter :prepare, only: [ :new ]
  
  before_filter :strip_virtual_solvents, only: [ :create, :update ]
  
  protected
  
  def prepare
    build_resource.tap do |r|
      r.existing_dilution = Dilution.first
      r.importance = -10
    end
  end    
  
  def strip_virtual_solvents
    params[:solvent][:composition_attributes] = params[:solvent].delete(:solvents_attributes)
  end
  
  private
  
  def solvent_params
    # It's mandatory to specify the nested attributes that should be whitelisted.
    # If you use `permit` with just the key that points to the nested attributes hash,
    # it will return an empty hash.
    params.require(:solvent).permit(:name, :cas, :symbol, :price, :logP, :notes, :importance, :existing_dilution_amount, :existing_dilution_id,
      composition_attributes: [:virtual_amount, :solvent_id, :_destroy, :id]
    )
   end
  
end
