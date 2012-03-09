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
    site = Site.enabled.find(params[:id])
    if site
      render :json => site.status_counts
    else
      render :text => "error"
    end
  end
  
end
