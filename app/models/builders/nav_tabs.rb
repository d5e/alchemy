class Builders::NavTabs
  
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::OutputSafetyHelper
  
  
  
  def initialize(container_name, context)
    @current_container_name = container_name
    @container_elements = []
    @template_object = context
    @active = 0
  end
  
  def add(*args)
    elements << args
  end
  
  def active(*args)
    @active = elements.size
    add *args
  end
  
  def render
    safe_join [render_tab_buttons, render_tab_contents], "\n"
  end
  
  
  
  protected

  def elements
    @container_elements
  end
  
  def current_container_name
    @current_container_name
  end
  
  def dom_tag(name)
    name.to_s.downcase.gsub(/[\s_\W]+/,'-').gsub(/[\s-]+\z/,'')
  end
  
  def li_class(tabs, classes="")
    classes << " active" if tabs.size == @active
    classes
  end
  
  def tr(tab)
    k = tab.first.gsub(/[\s-]+/,'_').underscore
    @template_object.t(:"view.tabs.#{k}")
  end
  
  def render_tab_buttons
    tabs = []
    elements.each do |tab|
      tabs << content_tag( :li, content_tag(:a, tr(tab), href: "##{dom_tag current_container_name}-tab-#{dom_tag tab.first}", :'data-toggle' => 'tab', role: :tab), class: li_class(tabs))
    end
    content_tag(:ul, safe_join(tabs, "\n"), class: "nav nav-tabs", role: "tablist")
  end
  
  def render_tab_contents
    tabs = []
    elements.each do |tab|
      tca = tab.clone
      name = tca.shift
      tabs << content_tag( :div, @template_object.render(*tca), class: li_class(tabs, 'tab-pane'), id: "#{dom_tag current_container_name}-tab-#{dom_tag name}")
    end
    content_tag( :div, safe_join(tabs, "\n"), class: "tab-content")
  end
  
end