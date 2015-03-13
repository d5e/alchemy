class SolventsController < InheritedResources::Base
      
  before_filter :prepare, only: [ :new ]
  
  def show
    @dilution = Dilution.find(params[:dilution_id]) if params[:dilution_id]
    super
  end

  def create
    # go into this if when a solution of an existing solution shall be created
    if (@existing_dilution_id = params[:solvent][:existing_dilution_id].to_i) > 0
      existing_dilution = Dilution.find(@existing_dilution_id)
      existing_solvent = existing_dilution.solvent
      substance = existing_dilution.substance
      @solvent = Solvent.new(solvent_params)
      if @solvent.pure_live?
        throw_error :empty
      elsif @solvent.existing_dilution_amount.to_f == 0.0
        throw_error :zero
      elsif @solvent.molecular_composition.to_set == existing_solvent.molecular_composition.to_set # molecular solvent constituition is equal to solvent const. of existing dilution do not create another solvent, just create another dilution
        
        debugs = %w( @solvent.existing_dilution_amount.to_f existing_dilution.concentration @solvent.total_composition_mass @solvent.existing_dilution_amount.to_f @solvent.inspect @solvent.solvent_ingredients.inspect @solvent.solvent_ingredients.all?(&:persisted?) @solvent.solvent_ingredients.to_a.sum(&:amount) @solvent.solvent_ingredients.map(&:amount) )
        debugs.each do |ss|
          Rails.logger.info "### #{ss}: #{eval(ss).inspect}"
        end
        concentration = @solvent.existing_dilution_amount * existing_dilution.concentration / (@solvent.total_composition_mass + @solvent.existing_dilution_amount)
        dil = Dilution.new substance: substance, solvent: existing_solvent, concentration: concentration
        if (dil.valid?)
          dil.save!
          redirect_to substance_path(substance)
        else
          throw_error :concentration, :dilutions
        end
      else
        # create solvent and then a specific dilution of 
        si = SolventIngredient.new(ingredient: existing_solvent, amount: @solvent.existing_dilution_amount * (1.0 - existing_dilution.concentration))
        
        debugs = %w(@solvent.existing_dilution_amount existing_dilution.concentration)
        debugs.each do |ss|
          Rails.logger.info "### #{ss}: #{eval(ss).inspect}"
        end
        
        @solvent.solvent_ingredients << si
        Rails.logger.info si.inspect
        @solvent.generate_name
        if @solvent.save
          concentration = @solvent.existing_dilution_amount.to_f * existing_dilution.concentration / (@solvent.total_composition_mass + existing_dilution.concentration * @solvent.existing_dilution_amount.to_f)
          dil = Dilution.new substance: substance, solvent: @solvent, concentration: concentration
          dil.save!
          redirect_to substance_path(substance)
        else
          @solvent.solvent_ingredients.delete si
          throw_error
        end
      end
    else
      create!
    end
  end
  
  protected
  
  def throw_error(type=nil, field=:solvent_ingredients)
    @solvent.errors.add field, type if type
    prepare @existing_dilution_id
    render :new
  end
  
  def prepare(existing_dilution_id=nil)
    return true unless (existing_dilution_id ||= params[:existing_dilution_id].to_i) > 0
    build_resource.tap do |r|
      r.existing_dilution = Dilution.find existing_dilution_id
      r.importance = -10
    end
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
