class MixingController < ApplicationController
  
  def new
    @families = []
    if params[:family_id]
      if (ids = params[:family_id].split(',')).size > 1
        @families = Family.where(id: ids)
      else
        @families << Family.find(params[:family_id])
      end
      @available_blends = @families.map(&:blends).flatten.compact.uniq
    else
      @available_blends = Blend.all
    end
  end
  
  def prepare
    blend_dom_ids = params[:selected_blend_ids].gsub(/[\.,\s]+/,' ').split(/\s/)
    @blends = blend_dom_ids.map{ |dom_id| Blend.find dom_id[/\d+/].to_i }
  end
  
  def create
    @new_blend = mix_blends if validate_params
  end
  
  protected
  
  # take dilution with highest available concentration in database
  def dilute_ess(ingredients)
    ingredients.each do |ing|
      next if ing.dilution
      ing.dilution = ing.substance.dilutions.order("concentration DESC").first
      next unless ing.dilution
      ing.amount /= ing.dilution.concentration
    end
  end
  
  # take dilution with highest concentration of all dilutions inside this mix of that substance
  def dilute_ing(ingredients, dilutions)
    ingredients.each do |ing|
      next if ing.dilution
      ddd = dilutions[ing.substance_id].first
      dilutions[ing.substance_id].each do |di|
        ddd = di if di.concentration > ddd.concentration
      end
      ing.dilution = ddd
      next unless ing.dilution
      ing.amount /= ing.dilution.concentration
    end
  end

  def mix_blends
    ingredients = {}
    dilutions = {}
    blends = []
    blends_with_ratio do |blend, ratio|
      Rails.logger.info "#{blend}-r: #{ratio} "
      blends << blend
      blend.ingredients.each do |ing|
        concentration = ing.dilution.concentration rescue 1.0
        if essence_strategy?
          next if concentration == 0.0
          new_amount = ing.amount * ratio * concentration
          merge_amount new_amount, ing, ingredients
        else
          if concentration == 0.0
            new_amount = ing.amount * ratio
            merge_amount new_amount, ing, ingredients, ing.dilution
          else
            # TODO => different kinds of solvents of mixed ingredients of the same substance are not kept this way
            # they would have to be added seperately depending on the dilution
            dilutions[ing.substance_id] ||= []
            dilutions[ing.substance_id] << ing.dilution
            new_amount = ing.amount * ratio * concentration
            merge_amount new_amount, ing, ingredients
          end
        end
      end
    end
    if essence_strategy?
      dilute_ess ingredients.values
    else
      dilute_ing ingredients.values, dilutions
    end
    new_blend = built_blend(blends)
    new_blend.ingredients << ingredients.values
    
    family_ids = blends.map(&:family_ids).reduce{|m,n| m & n }
    if family_ids.empty?
      family_ids = [blends.map(&:families).map(&:root).flatten.first.to_param] rescue []
    end
    new_blend.family_ids = family_ids
    
    new_blend.save
    
    # only auto resize if essence strategy
    new_blend.resize! params[:total_mass].to_f if essence_strategy?
    
    # TODO if ingredients strategy FILL UP missing amount with solvents
    
    new_blend
  end
  
  def blends_with_ratio(&block)
    # essence mixing actually does blend diluted ingredients (in concentrations as they appear in the source blends), but discards additional solvents
    if essence_strategy?
      percent = blend_params.values.map(&:to_f).sum
      total_mass = params[:total_mass].to_f
      adp = (total_mass * 1000.0) / percent
    end

    @composition_human = ""
    blend_params.each do |k,v|
      blend = Blend.find k.to_s[/\d+/]
      @composition_human << "#{v}mg #{blend.name}\n"
      if essence_strategy?
        Rails.logger.info "adp: #{adp} ;   v.to_f: #{v.to_f} ;   bmax: #{blend.essence_mass}"
        ratio = (adp * v.to_f) / blend.ingredient_weight
      else
        ratio = v.to_f == 0.0 ? 1.0 : (v.to_f / blend.total_mass)
      end
      yield(blend, ratio)
    end
  end
  
  def built_blend(blends)
    Blend.new( 
      name: params[:new_blend_name],
      sensory_tags: blends.map(&:sensory_tags).join("; "),
      notes: notes
     )
  end
  
  def notes
    s = "#{params[:strategy]} MIX of \n#{@composition_human}"
  end
  
  # amount => the amount in mg of raw material to add from the substance inside ing
  # ing    => the ingredient from where to take the substance
  # ingredients => a hash holding all new merged ingredients, hashed by their substance_ids
  # dilution => force a certain dilution (only necessary mixing pure solvents - soon deprecated)
  def merge_amount(amount, ing, ingredients, dilution=nil)
    key = ing.substance_id
    if ingredients[key]
      ingredients[key].amount += amount
    else
      ingredients[key] = new_ingredient(ing, amount, dilution)
    end
  end
  
  # def old_merge_amount(hash, key, value)
  #   if hash[key]
  #     hash[key].amount += value.amount
  #   else
  #     hash[key] = value
  #   end
  # end
  
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
      val = Numeric.parse_localized(val) if I18n.delocalization_enabled?
      result[key] = val if key.to_s[regex]
    end
    result
  end
  
  
  def essence_validation
    valid = true
    params.each do |key, val|
      if key.to_s[/_percent\z/] || key.to_s == 'total_mass'
        val = Numeric.parse_localized(val) if I18n.delocalization_enabled?
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
        val = Numeric.parse_localized(val) if I18n.delocalization_enabled?
        if val.to_f == 0.0 && val != ""
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
