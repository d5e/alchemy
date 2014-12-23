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
        if parent = resource_class.find(params[:parent_id]) rescue nil
          resource.color = parent.color
          if parent.name.strip[/\s\d{1,4}\z/]
            number = parent.name.strip[/\d+\z/].to_i + 1
            resource.name = "#{parent.name.gsub(/\d+\z/,'')} #{number}"
          elsif parent.name.strip[/\s\w{1,2}\z/] && 0 < (deputy = parent.name.strip[/\w+\z/].to_i(36))
            resource.name = "#{parent.name.gsub(/\w+\z/,'')} #{(deputy + 1).to_s(36).upcase}"
          else
            resource.name = "#{parent.name} Sub"
          end
          resource.tags = parent.tags
          resource.parent = parent
          @parent = parent
        end
      end
    end
  end
  
end
