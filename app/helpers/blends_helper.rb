module BlendsHelper

  # TODO use ElasticSearch here to get blends by tags count for performance increase
  def blends_by_exclusive_tags
    tag_counts = Hash.new(0)
    Blend.pluck(:sensory_tags).flatten.join(' ').gsub(/\W+/,' ').split(' ').each do |tag|
      tag_counts[tag] += 1
    end
    tcg = tag_counts.to_a.sort{ |a,b| a.last <=> b.last }
    available = Blend.pluck(:id)
    ordered = {}
    tcg.each do |tc|
      bs = Blend.where(:id => available).where("sensory_tags LIKE '%#{tc.first}%'")
      puts "##{tc.first}"
      ordered[tc.first] = bs.to_a
      available -= bs.map(&:id)
    end
    Rails.logger.info ordered.keys
    ordered.values.each do |vv|
      Rails.logger.info vv.map &:name
    end
    ordered
  end
  
end