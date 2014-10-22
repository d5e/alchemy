module ApplicationHelper
  
  def resource_class_name
    if defined?(resource_class)
      resource_class.model_name.to_s.underscore
    else
      controller_name.underscore.gsub("_controller",'')
    end
  end
  
  def concentration_human(concentration)
    concentration = concentration.concentration if concentration.is_a?(Blend)
    if concentration > 0.39
      "Huiles essentielles"
    elsif concentration > 0.197
      "Perfume extraits"
    elsif concentration > 0.1145
      "Eau de Parfum"
    elsif concentration > 0.068
      "Eau de Toilette"
    elsif concentration > 0.039
      "Eau de Cologne"
    elsif concentration > 0.0149
      "Eau Légère"
    elsif concentration > 0.5
      "Eau de solide"
    elsif concentration > 0.0
      "traces"
    else
      "inv"
    end
  end
  
  def substance_character 
    {
      'base' => ['amber, musk, cedar, sandal','#ebc8a6'],
      'base-citral' => ['citral, green, floral', '#bedc55'],
      'base-heart' => ['sweet, herbal','#eabfd1'],
      'heart' => ['floral','#c7afee'],
      'heart-top' => ['ozone, fresh, fruity','#adc5f4'],
      'top-floral' => ['flower','#bfedc9'],
      'top-citral' => ['citral','#e7ff9e'],
      'top-musk' => ['powdery, creamy, warm','#ffec83']
    }
  end
  
  def colored(record, options={})
    options.symbolize_keys!
    if record.respond_to?(:character) && record.character.present?
      options.merge!({ class: "#{options[:class]} color-#{record.character}" }) 
    end
    if record.respond_to?(:color) && record.color.present?
      options.merge!({ style: "#{options[:style]} background-color: ##{record.color};" }) 
      options.merge!({ class: "#{options[:class]} #{bg_color_class record.color}" }) 
    end
    options
  end
  
  def bg_color_class(hex)
    begin
      lum = hex_rgb_luminance(hex)
    rescue
      return nil
    end
    if lum > 200
      "bg-white"
    elsif lum > 128
      "bg-bright"
    elsif lum > 50
      "bg-dark"
    else
      "bg-black"
    end
  end
  
  def hex_rgb_luminance(hex)
    hex.gsub!(/[\s\#]/,'')
    if hex.size == 3
      r = hex[0,1] + hex[0,1]
      g = hex[1,1] + hex[1,1]
      b = hex[2,1] + hex[2,1]
    else
      r = hex[0,2]
      g = hex[2,2]
      b = hex[4,2]
    end
    int_rgb_luminance(r.to_i(16), g.to_i(16), b.to_i(16))
  end
  
  def int_rgb_luminance(r,g,b)
    ( 0.299 * r ** 2 + 0.587 * g ** 2 + 0.114 * b ** 2 ) ** 0.5
  end
  
  
end
