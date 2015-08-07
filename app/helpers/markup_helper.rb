module MarkupHelper

  def smarted(s)
    return s unless s.is_a?(String)
    linkable( simple_format s ).html_safe
  end

  def linkable(s)
    return s unless s.is_a?(String)
    s.gsub(/\"[^\n\"\t\r:]{2,40}\":\"https?:\/\/[^\n\"\t\r]{15,512}\"/) do |chunk|
      human = chunk.split('":"http').first.gsub(/\A\"/,'')
      href = chunk[/https?:\/\/[^\"]+/]
      link_to href, target: '_blank' do
        content_tag( :span, nil, class: 'glyphicon glyphicon-globe') + " " + (content_tag :span, human)
      end
    end
  end

  def tabbed(s)
    return s unless s.is_a?(String)
    Rails.logger.info "s inspect: #{s.inspect}"
    delimiter = /^\#[^\#]{2,40}\#\r?$/
    headlines = s.scan delimiter
    bodies = s.split(delimiter).select{|b| b.present? }
    pre = ""
    if headlines.size == (bodies.size - 1)
      pre = "<div class='panel-body'>#{smarted bodies.shift}</div>"
    elsif headlines.size == bodies.size
    else
      return s
    end
    html2 = nav_tabs( "tabable_#{rand(2e12).to_s(36)}") do |tabs|
      headlines.each do |hl|
        tabs.add hl.gsub(/\W+/,''), :inline => "<div class='panel-body'>#{smarted bodies.shift}</div>"
      end
    end
    pre.html_safe + html2.html_safe
  end

  # slow
  def stream_resource_links(s)
    return s unless s.is_a?(String)
    return s unless s[/\"\w+\"/]
    bnames = Blend.pluck(:name).map &:downcase
    bids = Blend.pluck :id
    snames = Substance.pluck(:name).map &:downcase
#    puts snames.inspect
    sids = Substance.pluck :id
    s.gsub(/\"[\w\ \-\,\.]{3,90}\"/) do |chunk|
      resource = nil
      name = chunk.gsub('"','').downcase
#      puts name.inspect
      if name[/\Ablend_\d+/]
        resource = Blend.where(id: chunk[/\d+/].to_i).first
      elsif name[/\Asubstance_\d+/]
        resource = Substance.where(id: chunk[/\d+/].to_i).first
      elsif ( i = bnames.index(name) )
#        puts "######"
        resource = Blend.where(id: bids[i.to_i]).first
      elsif ( i = snames.index(name) )
        resource = Substance.where(id: sids[i.to_i]).first
      end
      if resource
        link_to( resource, send("#{resource.class.name.downcase}_path", resource)).html_safe
      else
        chunk
      end
    end
    .html_safe
  end


end
