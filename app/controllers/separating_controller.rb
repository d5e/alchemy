class SeparatingController < ApplicationController
  
  helper_method :resource
  
  def prepare
  end

  def create
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
