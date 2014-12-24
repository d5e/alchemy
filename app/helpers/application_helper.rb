module ApplicationHelper
  
  def resource_class_name
    if defined?(resource_class)
      resource_class.model_name.to_s.underscore
    else
      controller_name.underscore.gsub("_controller",'')
    end
  end
  
  def t(key, options={})
    options.symbolize_keys!
    if options[:plain] && !I18n.exists?(key, options)
      key.to_s[/\w+\z/].humanize
    else
      super
    end
  end

  def available_dilutions
    dilutions = {}
    Dilution.all.each do |d|
      dilutions["s#{d.substance_id}"] ||= []
      dilutions["s#{d.substance_id}"] << {
        dilution_id: d.id,
        dilution_name: d.to_s
      }
    end
    dilutions
  end
  
  def dilutions_as_options(object=nil)
    Rails.logger.info I18n.locale
    dc = Dilution::CONCENTRATIONS.compact.uniq.map do |s|
      p = number_with_precision s * 100, precision: 8, strip_insignificant_zeros: true
      v = number_with_precision s, precision: 10, strip_insignificant_zeros: true
      Rails.logger.info "#{p}   #{v}"
      [ "#{p} %", v ]
    end
    options_for_select dc
  end
  
  def concentration_classes
    {
      0.39   =>   "Huiles essentielles",
      0.197  =>   "Perfume extraits",
      0.1145 =>   "Eau de Parfum",
      0.068  =>   "Eau de Toilette",
      0.039  =>   "Eau de Cologne",
      0.0149 =>   "Eau Légère",
      0.003  =>   "Eau de solide",
      0.0    =>   "traces"
    }
  end
  
  def concentration_human(concentration)
    concentration = concentration.concentration.to_f if concentration.is_a?(Blend)
    if concentration > 0.0
      concentration_classes.each do |p, n|
        return n if concentration > p
      end
    else
      "inv"
    end
  end
  
  # REFACTORING : replace css classes defintions by color values from here (?) / discard duplicates
  def substance_character
    {
      'base' => ['animalic, wood','#271c0f', '#a96834', '#d2a978'],
      'base-citral' => ['citral, green, floral', '#152107', '#488116', '#8eba47'],
      'base-heart' => ['sweet, herbal', '#231618', '#8c4d55', '#c1939a'],
      'heart' => ['other', '#251b26', '#9d65a1', '#cba7cd'],
      'heart-sweet' => ['sweet', '#2c1d23', '#d46c8c', '#e9acc1'],
      'heart-floral' => ['floral', '#241e2d', '#9670de', '#c7afee'],
      'heart-fresh' => ['water, ozone, green', '#0e202f', '#307ced', '#73b7f6'],
      'heart-citral' => ['citral, aldehylic', '#21270e', '#84a830', '#bcd174'],
      'heart-top' => ['ozone, fresh, fruity', '#1d242f', '#6d91e8', '#adc5f4'],
      'top-floral' => ['flower', '#222d25', '#89dc9a', '#bfedc9'],
      'top-citral' => ['citral, aldehylic', '#2c3119', '#d0ff5a', '#e7ff9e'],
      'top-fruity' => ['fruity, sweet, aldehylic', '#2d2831', '#deafff', '#eed5ff'],
      'top-warm' => ['powdery, creamy, musk', '#312d12', '#ffda3d', '#ffec83']
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
