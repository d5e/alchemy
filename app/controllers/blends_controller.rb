class BlendsController < InheritedResources::Base
  
  def adjust
    target_c = params[:concentration].to_f / 100.0
    resource.adjust! target_c
    redirect_to resource
  end

  def bottle
    respond_to do |format|
      format.js do
        if params[:amount_in_gram].to_f > 0 && params[:new_blend_name].present?
          new_bottle = resource_class.new(resource.attributes)
          new_bottle.name = params[:new_blend_name]
          new_bottle.id = nil
          new_bottle.parent = resource
          new_bottle.ingredients = []
          resource.ingredients.each do |ing|
            ing.id = nil
            new_bottle.ingredients << Ingredient.new(ing.attributes)
          end
          new_bottle.save
          success = new_bottle.resize! params[:amount_in_gram].to_f * 1000.0
          if new_bottle.errors.empty? && success
            render :js => "window.location ='#{url_for new_bottle}';"
          else
            render :js => "alert('#{new_bottle.errors.full_messages.join(" - ")}');"
          end
        else
          render :js => "alert('Please fill out all fields');"
        end
      end
    end
  end


  private
  
  def blend_params
    # It's mandatory to specify the nested attributes that should be whitelisted.
    # If you use `permit` with just the key that points to the nested attributes hash,
    # it will return an empty hash.
    params.require(:blend).permit(:name, :creation_at, :sensory_tags, :notes, :color, :locked, :hidden,
      ingredients_attributes: [:substance_id, :amount, :dilution_id, :id, :_destroy ]
    )
   end
  
end
