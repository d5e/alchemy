module Memorizable
  extend ActiveSupport::Concern

  included do
  end

  def memorize
    if (sticky_tab = params[:sticky_tab]) && (container_name = params[:container_name]) && params[:sticky_tab].to_i > -1
      session[:sticky_tabs] ||= {}
      session[:sticky_tabs][container_name.to_s] = sticky_tab.to_i
    end
    render js: ""
  end

end
