module ApplicationHelper
  
  def resource_class_name
    if defined?(resource_class)
      resource_class.model_name.to_s.underscore
    else
      controller_name.underscore.gsub("_controller",'')
    end
  end
  
  def substance_character 
    {
      'base' => ['amber, musk, cedar, sandal','#ebc8a6'],
      'base-heart' => ['sweet, herbal','#eabfd1'],
      'heart' => ['floral','#c7afee'],
      'heart-top' => ['ozone, fresh, fruity','#adc5f4'],
      'top-floral' => ['flower','#bfedc9'],
      'top-citral' => ['citral','#e7ff9e']
    }
  end
  
end
