class SitesController < ApplicationController
  layout "popup", :only => :popup
  
  def index
    @title = "Sites"
    if current_user.administrator?
      @page_heading = "All Sites"
      @sites = Site.unscoped.includes(:department)
    else
      @page_heading = "#{current_user.department.display_name} | Sites"
      @sites = Site.unscoped.scoped_by_department_id(current_user.department_id)
    end
    @sites = @sites.order(sort_column + " " + sort_direction).page(params[:page])
    @device_counts = Client.where(:site_id => @sites).group(:site_id).count
  end

  def show
    @title = @department.display_name
    if params[:sites].present?
      @sites = SiteDecorator.decorate(current_resource)
      @site_ids = @sites.map{ |s| s.id }
    else
      @sites = [SiteDecorator.new(current_resource)]
      @site_ids = @sites.map{ |s| s.id }
      if params.has_key? :partial
        render :partial => 'site_pane', :collection => @sites
      end
    end
  end
  
  def popup
    @sites = [SiteDecorator.new(current_resource)]
    @site_ids = @sites.map{|s| s.id }
  end
  
  def new
    @title = "New Site"
    @site = Site.new
  end

  def edit
    @title = "Edit Site"
    @site = current_resource
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
    @site = current_resource
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
    @site = current_resource
    @site.destroy
    flash[:success] = "Site removed."
    redirect_to sites_path
  end
  
  def refresh
    if params[:sites].present?
      @sites = SiteDecorator.decorate(current_resource)
      site_hash = Hash.new
      @sites.each do |site|
        site_hash[site.id] = site.client_pane(allow? :sites, :view_client_status_details, site)
      end
      render :json => site_hash
    else
      render :nothing => true
    end
  end
  
  private
  
  def current_resource
    @department ||= Department.find(params[:department_id]) if params[:department_id]
    @current_resource ||= case params[:action]
                          when 'show'
                            if params[:sites]
                              @department.sites.enabled.where(:short_name => params[:sites].split('/')).order(:display_name)
                            elsif params[:id]
                              Site.enabled.find(params[:id])
                            end
                          when 'refresh'
                            Site.enabled.where(:short_name => params[:sites].split('/')) if params[:sites]
                          else
                            Site.find(params[:id]) if params[:id]
                          end
  end
  
  def sort_column
    super(Site.column_names + ['departments.display_name'], 'sites.display_name')
  end
  
end
