module BlendsHelper

  def blend_link(blend, options={})
    options[:blend] = blend
    render '/blends/blend_link', options
  end

  # TODO use ElasticSearch here to get blends by tags count for performance increase
  def blends_by_tags
    tcg = Blend.pluck(:sensory_tags).flatten.join(' ').gsub(/\W+/,' ').split(' ').uniq
    tcg = tcg.sort!
    ordered = {}
    all_blends = Blend.all.to_a
    tcg.each do |tc|
      tag = tc.downcase
      ordered[tag] = all_blends.select{|blend| blend.sensory_tags[/\b#{tag}\b/i] }.to_a
    end
    Rails.logger.info ordered.keys
    ordered.values.each do |vv|
      Rails.logger.info vv.map &:name
    end
    ordered
  end
  
  def get_precision(float, ref=5)
    if params[:precision].nil? || params[:precision].to_s.downcase.to_sym == :auto
      precision = (ref - Math.log10(float)).round
      precision = 1 if precision < 2
      precision = 4 if precision == 3
      return precision
    elsif params[:precision]
      return params[:precision].to_i
    end
  end
  
  def precision_manually_zeroed?
    params[:precision] && params[:precision].to_i == 0
  end

end