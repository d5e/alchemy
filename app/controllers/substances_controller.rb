class SubstancesController < InheritedResources::Base

  def create
    create! do |success, failure|
      success.html { redirect_after_save }
    end
  end
  
  def update
    update! do |success, failure|
      success.html { redirect_after_save }
    end
  end
  
  def suggest
    @suggest = substance_auto_suggest params[:suggest].gsub(/\W+/,' ')
  end

  protected
  
  def substance_auto_suggest(string)
    response = Elasticsearch::Persistence.client.suggest \
      index: Substance.index_name,
      body: {
        substances_suggest: {
          text: string,
          completion: { field: 'name_suggest' }
        },
      }
    output_to_substance_ids = {}
    return {} unless response["substances_suggest"]
    response["substances_suggest"].first["options"].each do |item|
      output_to_substance_ids[ item["text"] ] = item["payload"]["resource_id"]
    end
    output_to_substance_ids
  end

  def redirect_after_save
    logger.info "redirect_after_save"
    if params[:create_new_after].in? ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES
      logger.info "redirect_after_save TRUE"
      flash[:notice] = [resource.name, "saved"]
      redirect_to :action => :new, :create_new_after => "1"
    else
      redirect_to :action => :show, :id => resource.id
    end
  end
  
  private
  
  def substance_params
    # It's mandatory to specify the nested attributes that should be whitelisted.
    # If you use `permit` with just the key that points to the nested attributes hash,
    # it will return an empty hash.
    params.require(:substance).permit(:name, :cas, :sensory_tags, :alt_names, :notes, :notes_alt_1, :notes_alt_2, :ifra_cat_4_limit,
      :price_per_quantity, :price_currency, :quantity_in_gram_of_raw_material,
      dilutions_attributes: [:solvent, :concentration, :intensity, :_destroy, :id]
    )
   end
end
