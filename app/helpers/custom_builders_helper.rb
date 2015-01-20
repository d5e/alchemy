module CustomBuildersHelper
  
  def nav_tabs(container_name, options={}, &block)
    options[:session] ||= session
    th = Builders::NavTabs.new(container_name, self, options)
    yield th
    th.render
  end

end