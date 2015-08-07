class SubstancesController < InheritedResources::Base
  
  respond_to :tex
  
  def index
    respond_to do |format|
      format.tex
      format.html
    end
  end
  
  def report
    @style = :report
    respond_to do |format|
      format.tex { render :action => :index }
    end
  end

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
    @suggest = substance_auto_suggest params[:suggest].gsub(/\W+/,' ') rescue nil
    @blends_suggest = blends_auto_suggest params[:suggest].gsub(/\W+/,' ') rescue nil
  end
  
  def refresh_elastic
    respond_to do |format|
      format.js do
        Substance.import force: true
        render js: "$('a.refresh-elastic').remove();"
      end
    end
  end
  
  def add_dilution_to_blend
    respond_to do |format|
      format.js do
        begin
          blend = Blend.find(params[:blend_id])
          @dilution = Dilution.find(params[:dilution_id])
          blend.ingredients << Ingredient.new(:dilution_id => @dilution.id, :substance_id => resource.id, :amount => 1)
        rescue Exception => e
          render :js => "alert('error: #{e.message}');"
        end
      end
    end
  end

  def molecule
    cas = nil
    resource.cas do |c|
      cas = c
      break
    end
    cas = params[:cas] if params[:cas].present?
    send_data Molpic.fetch(cas), type: "image/jpeg", disposition: "inline"
  end

  protected
  
  def substance_auto_suggest(string)
    response = Elasticsearch::Persistence.client.suggest \
      index: Substance.index_name,
      body: {
        substances_suggest: {
          text: string,
          completion: { field: 'name_suggest', size: 9 },
        },
        substances_suggest_tags: {
          text: string,
          completion: { field: 'tags_suggest', size: 13 }
        }
      }
    result = {}
    return {} unless response["substances_suggest"]
    response["substances_suggest"].first["options"].each do |item|
      result[ item["payload"]["resource_id"] ] = {
        name: item["text"],
        character: item["payload"]["character"]
      }
    end
    response["substances_suggest_tags"].first["options"].each do |item|
      result[ item["payload"]["resource_id"] ] = {
        name: item["text"],
        character: item["payload"]["character"]
      }
    end
    result
  end
  
  def blends_auto_suggest(string)
    response = Elasticsearch::Persistence.client.suggest \
      index: Blend.index_name,
      body: {
        blends_suggest: {
          text: string,
          completion: { field: 'name_suggest', size: 21 }
        }
      }
    result = {}
    return {} unless response["blends_suggest"]
    response["blends_suggest"].first["options"].each do |item|
      result[ item["payload"]["resource_id"] ] = {
        name: item["text"],
        color: item["payload"]["color"]
      }
    end
    result
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
    params.require(:substance).permit(:name, :cas, :sensory_tags, :alt_names, :notes, :notes_alt_1, :notes_alt_2, :ifra_cat_4_limit, :character,
      :price_per_quantity, :price_currency, :quantity_in_gram_of_raw_material, :vp_mmHg_25C,
      dilutions_attributes: [:solvent_id, :concentration, :intensity, :_destroy, :id]
    )
   end
end
