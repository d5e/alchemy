class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :set_locale
  
  I18n.config.enforce_available_locales = false
  I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
  I18n.fallbacks.map('de' => 'en')
  I18n.fallbacks.map('en' => 'de')
  
  DEFAULT_LOCALE = :en
  
  protected
  
  def set_locale(locale=nil)
    locale ||= session[:locale]
    locale ||= DEFAULT_LOCALE
    I18n.locale = locale.to_sym
  end
  
  
end
