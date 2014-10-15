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

  protected

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
      dilutions_attributes: [:solvent, :concentration, :intensity, :_destroy, :id]
    )
   end
end
