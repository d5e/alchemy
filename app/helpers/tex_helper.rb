module TexHelper
  
  REGULAR_SPECIAL_CHARACTERS = %w(# $ % ^ & _ { } ~ \\)
  
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
    etex(stringy).gsub(/\n/,'\\\\').html_safe
  end

  
  
end