class FamiliesController < InheritedResources::Base

  private
  
  def family_params
    # It's mandatory to specify the nested attributes that should be whitelisted.
    # If you use `permit` with just the key that points to the nested attributes hash,
    # it will return an empty hash.
    params.require(:family).permit( :parent_id, :name, :color, :tags, :notes, :selected_blend_ids )
  end
  
  def root_families
    collection.root
  end
  
  def build_resource
    super.tap do |res|
      if params[:parent_id]
        resource.parent_id = params[:parent_id]
        if parent = resource_class.find(params[:parent_id]) rescue nil
          resource.color = parent.color
          lb = parent.name.strip[parent.name.strip.size-1,1]
          resource.name = "#{parent.name.strip[0,parent.name.strip.size-1]}#{(lb.ord + 1).chr}"
          resource.tags = parent.tags
          @parent = parent
        end
      end
    end
  end
  
end
