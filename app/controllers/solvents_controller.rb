class SolventsController < InheritedResources::Base
      
  before_filter :prepare, only: [ :new ]
  
  protected
  
  def prepare
    # build_resource.tap do |r|
    #   r.existing_dilution = Dilution.first
    #   r.importance = -10
    # end
  end    
  
  private
  
  def solvent_params
    # It's mandatory to specify the nested attributes that should be whitelisted.
    # If you use `permit` with just the key that points to the nested attributes hash,
    # it will return an empty hash.
    params.require(:solvent).permit(:name, :cas, :symbol, :price, :logP, :notes, :importance, :existing_dilution_amount, :existing_dilution_id,
      solvent_ingredients_attributes: [ :amount, :ingredient_id, :_destroy, :solvent_id, :id ]
    )
   end
  
end
