class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    if signed_in?
      redirect_to root_url, :flash => { :error => exception.message }
    else
      store_location
      redirect_to login_path, :flash => { :error => "Please sign in to access this page." }
    end
  end
end
