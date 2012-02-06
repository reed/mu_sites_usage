class SitesController < ApplicationController
  def index
  end

  def show
    @department = Department.find(params[:department_id])
    if params[:sites].present?
      @sites = SiteDecorator.decorate(@department.sites.where(:short_name => params[:sites].split('/')).order(:display_name))
    else
      @sites = [SiteDecorator.find(params[:id])]
      if params.has_key? :partial
        render :layout => false
      else
        render 'show'
      end
    end
  end
  
  def refresh
    if params[:sites].present?
      @sites = SiteDecorator.decorate(Site.where(:short_name => params[:sites].split('/')))
      site_hash = Hash.new
      @sites.each do |site|
        site_hash[site.id] = site.client_pane
      end
      render :json => site_hash
    else
      render :nothing => true
    end
  end
end
