class BlendsController < InheritedResources::Base
  

  
  
  private
  
  def blend_params
    # It's mandatory to specify the nested attributes that should be whitelisted.
    # If you use `permit` with just the key that points to the nested attributes hash,
    # it will return an empty hash.
    params.require(:blend).permit(:name, :creation_at, :sensory_tags, :notes, 
      ingredients_attributes: [:substance_id, :amount, :id]
    )
   end
  
end
