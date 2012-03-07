class SitesController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:show, :refresh]
  helper_method :sort_column, :sort_direction
  
  def index
    @title = "Sites"
    @page_heading = current_user.administrator? ? "All Sites" : "#{current_user.department.display_name} | Sites"
    @sites = @sites.unscoped.includes(:department).order(sort_column + " " + sort_direction).page(params[:page])
    @device_counts = Client.where(:site_id => @sites).group(:site_id).count
  end

  def show
    @department = Department.find(params[:department_id])
    @title = @department.display_name
    if params[:sites].present?
      @sites = SiteDecorator.decorate(@department.sites.enabled.where(:short_name => params[:sites].split('/')).order(:display_name))
      @site_ids = @sites.map{|s| s.id }
    else
      @sites = [SiteDecorator.new(Site.enabled.find(params[:id]))]
      @site_ids = @sites.map{|s| s.id }
      if params.has_key? :partial
        render :partial => 'site_pane', :collection => @sites
      else
        render 'show'
      end
    end
  end
  
  def new
    @title = "New Site"
    @site = Site.new
  end

  def edit
    @title = "Edit Site"
    @site = Site.find(params[:id])
  end
  
  def create
    if current_user.administrator? && params[:site][:department_id].present?
      @department = Department.find(params[:site][:department_id])
    end
    @department ||= current_user.department
    @site = @department.sites.build(params[:site]) 
    if @site.save
      Site.refilter_clients
      flash[:success] = "Successfully added #{@site.display_name}"
      redirect_to sites_path
    else
      @title = "New Site"
      render 'new'
    end
  end
   
  def update
    @site = Site.find(params[:id])
    new_filter = params[:site][:name_filter].present? && params[:site][:name_filter] != @site.name_filter
    respond_to do |format|
      if @site.update_attributes(params[:site])
        Site.refilter_clients if new_filter
        format.html { 
          flash[:success] = "Site successfully updated."
          redirect_to(sites_path) 
        }
        format.json { respond_with_bip(@site) }
      else
        format.html { 
          @title = "Edit Site"
          render :action => "edit" 
        }
        format.json { respond_with_bip(@site) }
      end
    end
  end

  def destroy
    @site = Site.find(params[:id])
    @site.destroy
    flash[:success] = "Site removed."
    redirect_to sites_path
  end
  
  def refresh
    if params[:sites].present?
      @sites = SiteDecorator.decorate(Site.enabled.where(:short_name => params[:sites].split('/')))
      site_hash = Hash.new
      @sites.each do |site|
        site_hash[site.id] = site.client_pane(can? :view_client_status_details, site)
      end
      render :json => site_hash
    else
      render :nothing => true
    end
  end
  

  
  private
  
  def sort_column
    (Site.column_names + ["departments.display_name"]).include?(params[:sort]) ? params[:sort] : "sites.display_name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end
