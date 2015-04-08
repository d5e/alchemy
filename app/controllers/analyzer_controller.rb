class AnalyzerController < ApplicationController
  
  helper_method :comparator
  
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
    Blend.where( id: param_ids ).order("FIELD(id, #{param_ids.join(',')})") if param_ids
  end
  
  def param_ids
    if p = params[:blend_ids]
      p.gsub(/[\s;,\-]+/,',').split(',').map(&:to_i)
    elsif p = params[:selected_blend_ids]
      p.gsub(/([\s;,\-\+\ ]+)|(blend_)/,',').split(',').map(&:to_i)
    end
  end
  
end
