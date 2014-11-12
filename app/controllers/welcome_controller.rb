class WelcomeController < ApplicationController
  
  ALLOWED_SESSION_VARIABLES = %w(locale)

  def index
  end

  def set_session_variables
    key = params[:key].to_s.gsub(/\W+/,'')[0,70]
    unless key.in?(ALLOWED_SESSION_VARIABLES)
      render :text => "SETTING NOT ALLOWED", status: 400
    end
    val = params[:value].to_s.gsub(/\W+/,'')
    session[key.to_sym] = val
    respond_to do |f|
      f.html{ request.env["HTTP_REFERER"].present? ? redirect_to(:back) : render(text: "OK") }
      f.js  { render js: "window.location = (window.location + '' ).replace(/#.*/,'');" }
    end
  end
  
end
