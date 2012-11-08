class DepartmentsController < ApplicationController
  
  def index
    @title = "Departments"
    @page_heading = "Departments"
    @departments = DepartmentDecorator.all
  end

  def show
    @department = DepartmentDecorator.find(params[:id])
    @sites = @department.sites.enabled.joins(:clients).uniq
    @sites = @sites.external unless allow? :sites, :view_internal_sites
    if @sites.any?
      @types = @sites.collect{|s| s.site_type}.uniq
      if params[:type].present?
        redirect_to @department unless @sites.pluck(:site_type).include?(params[:type])
        @site_type = params[:type]
      else
        type_counts = @sites.reorder('').group(:site_type).count
        @site_type = type_counts.has_key?("general_access") ? "general_access" : type_counts.max_by{|k,v| v}[0]
      end
      @sites = @sites.where(:site_type => @site_type)
      @status_counts = Site.status_counts_by_type(@sites)
    end
    @title = @department.display_name
  end

  def new
    @title = "New Department"
    @department = Department.new
  end

  def edit
    @title = "Edit Department"
    @department = current_resource
  end
  
  def create
    @department = Department.new(params[:department])
    if @department.save
      flash[:success] = "Department created."
      redirect_to @department
    else
      @title = "New Department"
      render 'new'
    end
  end

  def update
    @department = current_resource
    if @department.update_attributes(params[:department])
      flash[:success] = "Department updated."
      redirect_to @department
    else
      @title = "Edit Department"
      render 'edit'
    end
  end

  def destroy
    @department = current_resource
    @department.destroy
    flash[:success] = "Department removed."
    redirect_to departments_path
  end

  private
  
  def current_resource
    @current_resource ||= Department.find(params[:id]) if params[:id]
  end
end
