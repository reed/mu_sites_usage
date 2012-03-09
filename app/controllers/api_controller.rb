class ApiController < ApplicationController
  
  def index
    @title = "API"
    @departments = Department.all
    render 'api'
  end
  
  def sites
    if params[:sites].present?
      @sites = SiteDecorator.decorate(Site.enabled.where(:short_name => params[:sites].split('/')).order(:display_name))
    end
    render 'sites', :formats => [:json]
  end
  
  def counts
    if Site.enabled.exists?(params[:id])
      site = Site.enabled.find(params[:id])
      render :json => site.status_counts
    else
      render :text => "error"
    end
  end
  
end
