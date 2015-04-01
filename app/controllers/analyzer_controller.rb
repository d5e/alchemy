class AnalyzerController < ApplicationController
  
  helper_method :comparator
  
  def comparison
  end
  
  protected
  
  def comparator
    @comparator ||= initialize_comparator
  end
  
  def initialize_comparator
    Comparator.new blends_from_params
  end
  
  def blends_from_params
    Blend.where( id: params[:blend_ids].gsub(/[\s;,\-]+/,',').split(',') ) if params[:blend_ids]
  end
  
  
end
