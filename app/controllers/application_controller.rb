class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  
  before_filter :authorize
  before_filter :remove_jquery_cache_param
  
  delegate :allow?, to: :current_permission
  helper_method :allow?
  
  delegate :allow_param?, to: :current_permission
  helper_method :allow_param?
  
  def permitted_params
    @permitted_params ||= PermittedParams.new(params, current_user)
  end
  helper_method :permitted_params
  
  private
  
  def current_permission
    @current_permission ||= Permissions.permission_for(current_user)
  end
  
  def current_resource
    nil
  end
  
  def filter_resources
    if current_resource.kind_of? ActiveRecord::Relation 
      filtered_resources = current_permission.filter_resources(params[:controller], params[:action], current_resource)
      @current_resource = filtered_resources if filtered_resources.any?
    end
    filtered_resources.present?
  end
  
  def authorize
    if filter_resources || current_permission.allow?(params[:controller], params[:action], current_resource)
      current_permission.permit_params! params
    else
      if signed_in?
        redirect_to root_url, :flash => { :error => 'Not Authorized' }
      else
        store_location
        redirect_to login_path, :flash => { :error => "Please sign in to access this page." }
      end
    end
  end
  
  def remove_jquery_cache_param
    params.delete :_
  end
  
  def sort_column(columns, default)
    columns.include?(params[:sort]) ? params[:sort] : default
  end
  helper_method :sort_column
  
  def sort_direction(default = 'asc')
    %w[asc desc].include?(params[:direction]) ? params[:direction] : default
  end
  helper_method :sort_direction
end
