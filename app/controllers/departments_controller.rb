class DepartmentsController < ApplicationController
  load_and_authorize_resource
  
  def index
    @title = "Departments"
    @page_heading = "Departments"
    @departments = DepartmentDecorator.all
  end

  def show
    @department = DepartmentDecorator.find(params[:id])
    @sites = @department.sites.enabled
    if @sites.any?
      if params[:type].present?
        redirect_to Department.find(params[:id]) unless @sites.pluck(:site_type).include?(params[:type])
        @site_type = params[:type]
      else
        @site_type = @sites.group(:site_type).count.max_by{|k,v| v}[0]
      end
      @sites = @sites.where(:site_type => @site_type)
    end
    @title = @department.display_name
  end

  def new
    @title = "New Department"
    @department = Department.new
  end

  def edit
    @title = "Edit Department"
    @department = Department.find(params[:id])
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
    @department = Department.find(params[:id])
    if @department.update_attributes(params[:department])
      flash[:success] = "Department updated."
      redirect_to @department
    else
      @title = "Edit Department"
      render 'edit'
    end
  end

  def destroy
    @department = Department.find(params[:id])
    @department.destroy
    flash[:success] = "Department removed."
    redirect_to departments_path
  end

end
