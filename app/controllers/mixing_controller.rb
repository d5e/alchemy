class MixingController < ApplicationController
  
  def prepare
    blend_dom_ids = params[:selected_blend_ids].gsub(/[\.,\s]+/,' ').split(/\s/)
    @blends = blend_dom_ids.map{ |dom_id| Blend.find dom_id[/\d+/].to_i }
  end
  
  def create
    @new_blend = mix_blends if validate_params
  end
  
  protected
  
  def dilute(ingredients)
    ingredients.each do |ing|
      next if ing.dilution
      ing.dilution = ing.substance.dilutions.order("concentration DESC").first
      next unless ing.dilution
      ing.amount /= ing.dilution.concentration
    end
  end

  def mix_blends
    ingredients = {}
    blends = []
    blends_with_ratio do |blend, ratio|
      Rails.logger.info "#{blend}-r: #{ratio} "
      blends << blend
      blend.ingredients.each do |ing|
        concentration = ing.dilution.concentration rescue 1.0
        if essence_strategy?
          next if concentration == 0.0
          new_amount = ing.amount * ratio * concentration
          Rails.logger.info "  #{ing.substance} : #{new_amount}   by con: #{concentration}"
        else
          if concentration == 0.0
            new_amount = ing.amount * ratio
          else
            new_amount = ing.amount * ratio * concentration
          end
        end
        merge_amount ingredients, ing.substance_id, new_ingredient(ing, new_amount, ing.dilution)
        Rails.logger.info "    new ing amount : #{ingredients[ing.substance_id].amount}"
      end
    end
    dilute ingredients.values
    new_blend = built_blend(blends)
    new_blend.ingredients << ingredients.values
    new_blend.save
    new_blend
  end
  
  def blends_with_ratio(&block)
    # essence mixing actually does blend diluted ingredients (in concentrations as they appear in the source blends), but discards additional solvents
    if params[:strategy] == 'essences'
      percent = blend_params.values.map(&:to_f).sum
      total_weight = params[:total_weight].to_f
      adp = (total_weight * 1000.0) / percent
    elsif params[:strategy] == 'ingredients'
    end
    
    blend_params.each do |k,v|
      blend = Blend.find k.to_s[/\d+/]
      if essence_strategy?
        Rails.logger.info "adp: #{adp} ;   v.to_f: #{v.to_f} ;   bmax: #{blend.essence_weight}"
        ratio = (adp * v.to_f) / blend.ingredient_weight
      else
        ratio = v.to_f / blend.total_weight
      end
      yield(blend, ratio)
    end
  end
  
  def built_blend(blends)
    Blend.new( 
      name: params[:new_blend_name],
      sensory_tags: blends.map(&:sensory_tags).join("; "),
      notes: "#{params[:strategy]} MIX of #{blends.map(&:name).join(', ')}"
     )
  end
  
  def merge_amount(hash, key, value)
    if hash[key]
      hash[key].amount += value.amount
    else
      hash[key] = value
    end
  end
  
  def new_ingredient(source_ingredient, amount, dilution=nil)
    Ingredient.new substance_id: source_ingredient.substance_id, amount: amount, dilution: dilution
  end
  
  def essence_strategy?
    return true if params[:strategy] == 'essences'
    return false if params[:strategy] == 'ingredients'
    raise "unknown mixing strategy"
  end
  
  def blend_params
    regex = essence_strategy? ? /_percent\z/ : /_mg\z/
    result = {}
    params.each do |key, val|
      result[key] = val if key.to_s[regex]
    end
    result
  end
  
  
  def essence_validation
    valid = true
    params.each do |key, val|
      if key.to_s[/_percent\z/] || key.to_s == 'total_weight'
        unless val.to_f > 0.0
          valid = false 
          add_error key
        end
      end
    end
    valid
  end
  
  def ingredients_validation
    valid = true
    params.each do |key, val|
      if key.to_s[/_mg\z/]
        unless val.to_f > 0.0
          valid = false 
          add_error key
        end
      end
    end
    valid
  end
  
  def validate_params
    add_error 'new_blend_name' if params[:new_blend_name].blank? || Blend.where(:name => params[:new_blend_name]).exists?
    if params[:strategy] == 'essences'
      essence_validation
    elsif params[:strategy] == 'ingredients'
      ingredients_validation
    else
      add_error "Mixing Strategy missing"
    end
    @errors ||= []
    !@errors.present?
  end
  
  def add_error(s)
    @errors ||= []
    @errors << s
  end
  

end
