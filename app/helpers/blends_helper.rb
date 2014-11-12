module BlendsHelper

  # TODO use ElasticSearch here to get blends by tags count for performance increase
  def blends_by_tags
    tag_counts = Hash.new(0)
    Blend.pluck(:sensory_tags).flatten.join(' ').gsub(/\W+/,' ').split(' ').each do |tag|
      tag_counts[tag] += 1
    end
    tcg = tag_counts.to_a.sort{ |a,b| a.last <=> b.last }
    ordered = {}
    all_blends = Blend.all.to_a
    tcg.each do |tc|
      tag = tc.first.downcase
      ordered[tag] = all_blends.select{|blend| blend.sensory_tags[/\b#{tag}\b/i] }.to_a
    end
    Rails.logger.info ordered.keys
    ordered.values.each do |vv|
      Rails.logger.info vv.map &:name
    end
    ordered
  end
  
end