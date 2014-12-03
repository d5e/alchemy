class SeparatingController < ApplicationController
  
  helper_method :resource
  
  def prepare
  end

  def create
    respond_to do |format|
      format.js do
        
        Rails.logger.info "####"
        Rails.logger.info params[:separator]
        
        blends = {}
        
        params[:separator].each do |trunk, items|
            blends[trunk] ||= Blend.new(
              name: "#{resource.name} _#{trunk}",
              parent_id: resource.id,
              hidden: true,
              color: resource.color,
              sensory_tags: trunk,
              notes: "#{trunk} separated from blend #{resource.id}, #{resource.name}"
            ) 
            items.each do |item|
              raise "unprocessable ingredient: #{item.inspect}" unless item.to_s[/\Aingredient_\d+\z/]
              ing = Ingredient.find(item.to_s[/\d+\z/].to_i)
              blends[trunk].ingredients << Ingredient.new(substance_id: ing.substance_id, dilution_id: ing.dilution_id, amount: ing.amount)
            end
        end
        
        blends.values.map &:save
        
        if blends.values.map(&:errors).any?(&:present?)
          render :js => "alert('#{blends.values.map(&:errors).map(&:full_messages).join("\\n")}');"
        else
          turbo_redirect blend_path(resource)
        end
      end
    end
  end
  
  def resource
    Blend.find params[:id]
  end
  
  protected
  
  def validate_params
#    add_error 'new_blend_name' if params[:new_blend_name].blank? || Blend.where(:name => params[:new_blend_name]).exists?
    @errors ||= []
    !@errors.present?
  end
  
  def add_error(s)
    @errors ||= []
    @errors << s
  end
  

end
