class DepartmentsController < ApplicationController
  def index
    @title = "Departments"
    @page_heading = "Departments"
    @departments = Department.all
  end

  def show
    @department = Department.find(params[:id])
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
