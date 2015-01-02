class BlendsController < InheritedResources::Base
  
  include ActionView::Helpers::JavaScriptHelper
  
  helper_method :blends_for_parentship
  
  def adjust
    target_c = to_f(params[:concentration]) / 100.0
    resource.adjust! target_c
    redirect_to resource
  end

  def bottle
    respond_to do |format|
      format.js do
        if to_f(params[:amount_in_gram]) > 0 && params[:new_blend_name].present?
          new_bottle = resource_class.new(resource.attributes)
          new_bottle.unlock_silent
          new_bottle.name = params[:new_blend_name]
          new_bottle.id = nil
          new_bottle.parent = resource
          new_bottle.families = resource.families
          new_bottle.ingredients = []
          resource.ingredients.each do |ing|
            ing.id = nil
            ing.blend = nil
            new_bottle.ingredients << Ingredient.new(ing.attributes)
          end
          new_bottle.save
          success = new_bottle.resize! mg: to_f(params[:amount_in_gram]) * 1000.0
          if new_bottle.errors.empty? && success
            render js: "window.location ='#{url_for new_bottle}';"
          else
            render js: "alert('#{new_bottle.errors.full_messages.join(" - ")} \\n #{j new_bottle.inspect}');"
          end
        else
          render js: "alert('Please fill out all fields');"
        end
      end
    end
  end

  def resize
    respond_to do |format|
      format.js do
        if to_f(params[:gram]) > 0 && params[:strategy].to_s[/gram/]
          resize! mg: to_f(params[:gram]) * 1000
        elsif to_f(params[:mg]) > 0 && params[:strategy].to_s[/mg/]
          resize! mg: to_f(params[:mg])
        elsif to_f(params[:factor]) > 0 && params[:strategy].to_s[/factor/]
          resize! factor: to_f(params[:factor])
        else
          render js: "alert('Please fill out all fields');"
        end
      end
    end
  end

  private
  
  def build_resource
    super.tap do |res|
      begin
        res.families << Family.where(id: params[:family_ids].to_s.split(',')) if params[:family_ids].present?
      rescue Exception => e
        raise params[:family_ids].inspect
      end
    end
  end
  
  def blends_for_parentship
    []
    return resource.families.map(&:blends).flatten.compact.uniq if resource && resource.families
    Blend.all
  end
  
  def to_f(f)
    I18n.delocalization_enabled? ? Numeric.parse_localized(f).to_f : f.to_f
  end
  
  def resize!(opts)
    return render js: "alert('cannot resize locked blend');" if resource.locked?
    if resource.resize! opts
      turbo_reload
    else
      render js: "alert('unknown error');"
    end
  end
  
  def blend_params
    # It's mandatory to specify the nested attributes that should be whitelisted.
    # If you use `permit` with just the key that points to the nested attributes hash,
    # it will return an empty hash.
    params.require(:blend).permit(:name, :creation_at, :sensory_tags, :notes, :color, :locked, :hidden, :parent_id, :family_ids,
      ingredients_attributes: [:substance_id, :amount, :dilution_id, :highlighted, :id, :_destroy ]
    )
   end
  
end
