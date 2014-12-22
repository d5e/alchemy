class FamiliesController < InheritedResources::Base

  private
  
  def family_params
    # It's mandatory to specify the nested attributes that should be whitelisted.
    # If you use `permit` with just the key that points to the nested attributes hash,
    # it will return an empty hash.
    params.permit(:family).permit( "parent_id", "name", "color", "tags", "notes" )
    params.permit(:selected_blend_ids)
  end
  
  def root_families
    collection.root
  end
  
end
