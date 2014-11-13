module BlendsHelper

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
  
end