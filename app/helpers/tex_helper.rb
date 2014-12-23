module TexHelper

  REGULAR_SPECIAL_CHARACTERS = %w(" # $ % ^ & _ { } ~ \\)

  # escape tex
  def etex(stringy)
    return stringy unless stringy
    escaped = stringy.gsub /[#{Regexp.quote REGULAR_SPECIAL_CHARACTERS.join ''}]/ do |c|
      if c == '\\'
        '\textbackslash'
      else
        "\\#{c}"
      end
    end
    escaped.html_safe
  end

  def bretex(stringy)
    nl = ' \newline '
    etex(stringy).gsub(/[\r\n]+/){|c| c.scan("\n").size > 2 ? nl + nl : nl }.html_safe
  end

  def tex_readable_links(s)
    return s unless s.is_a?(String)
    s2 = s.gsub(/\"[^\n\"\t\r:]{2,40}\":\"https?:\/\/[^\n\"\t\r]{15,512}\"/) do |chunk|
      human = chunk.split('":"http').first.gsub(/\A\"/,'')
      href = chunk[/https?:\/\/[^\"]+/]
      "#{human} - \x0B#{href}\x17"
    end
    bretex(s2).gsub("\x0B",'\url{').gsub("\x17",'}').html_safe
  end
  
  def tex_c
    return @tex_c if @tex_c
    @tex_c = %w(chapter section subsection subsubsection subsubsubsection)
    if @style == :report
      elsif @style == :book
    else
      @tex_c.shift
    end
    @tex_c
  end
  
  def tex_doc_class
    return @tex_doc_class if @tex_doc_class
    if @tex_doc_class == :report
      '\documentclass{report}'
    elsif @tex_doc_class == :book
      '\documentclass{book}'
    else
      '\documentclass{scrartcl}'
    end
    @tex_doc_class
  end

end