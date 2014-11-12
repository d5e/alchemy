module CustomBuildersHelper
  
  def nav_tabs(container_name, &block)
    th = Builders::NavTabs.new(container_name, self)
    yield th
    th.render
  end

end