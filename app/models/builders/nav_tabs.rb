class Builders::NavTabs
  
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::OutputSafetyHelper
  
  
  
  def initialize(container_name, context, options={})
    @current_container_name = container_name
    @container_elements = []
    @template_object = context
    @options = options.symbolize_keys
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
    prepare_render
    safe_join [render_tab_buttons, render_tab_contents], "\n"
  end
  
  protected
  
  def prepare_render
    stick if sticky?
  end
  
  def sticky?
    @options[:sticky]
  end
  
  def stick
    dummy = @options[:session][:sticky_tabs][@current_container_name.to_s] rescue nil
    return unless dummy
    @active = dummy
  end
  
  def with_stickyness(i, options={})
    controller = @template_object.controller
    uri = @template_object.send "memorize_#{controller.controller_path}_path"
    options.merge onclick: "$.getScript('#{uri}?container_name=#{@current_container_name}&sticky_tab=#{i}');"
  end

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
    elements.each_with_index do |tab,i|
      options = { href: "##{dom_tag current_container_name}-tab-#{dom_tag tab.first}", :'data-toggle' => 'tab', role: :tab }
      options = with_stickyness(i,options) if sticky?
      tabs << content_tag( :li, content_tag(:a, tr(tab), options), class: li_class(tabs))
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