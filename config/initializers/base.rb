module ActionView
  module Helpers
    module Tags # :nodoc:
      class Base
        
        alias_method :initialize_original, :initialize
        
        def initialize(object_name, method_name, template_object, options = {})
          h = options
          if h.is_a?(Hash) && h.symbolize_keys[:placeholder] == :default
            h[:placeholder] = object_class(object_name).human_attribute_name method_name
          end
          if h.is_a?(Hash) && h.symbolize_keys[:prompt] == :default
            h[:prompt] = object_class(object_name).human_attribute_name method_name
          end

          initialize_original object_name, method_name, template_object, options
        end
        
        def object_class(object_name)
          if object_name["["]
            on2 = object_name.gsub(/(\w+\[)+/, '').gsub(/_attributes.*/i,'').singularize
          else
            on2 = object_name
          end
          on2.camelcase.constantize
        end
        
      end
    end
  end
end

