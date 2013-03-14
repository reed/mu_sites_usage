class UsersController < ApplicationController
  
  def index
    @title = "Users"
    if current_user.administrator?
      @page_heading = "All Users"
      @users = User.unscoped.includes(:department)
    else
      @page_heading = "#{current_user.department.display_name} Users"
      @users = User.beneath_me(current_user)
    end
    @users = @users.order(sort_column + " " + sort_direction).page(params[:page])
  end

  def new
    @title = "New User"
    @user = User.new
  end

  def create
    if current_user.administrator? && params[:user][:department_id].present?
      @department = Department.find(params[:user][:department_id])
    end
    @department ||= current_user.department
    @user = @department.users.build(params[:user]) 
    if @user.save
      flash[:success] = "Successfully added #{@user.name}"
      redirect_to users_path
    else
      @title = "New User"
      render 'new'
    end
  end
    
  def edit
    @title = "Edit User"
    @user = current_resource
  end
  
  def update
    @user = current_resource
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { 
          flash[:success] = "User successfully updated."
          redirect_to(users_path) 
        }
        format.json { respond_with_bip(@user) }
      else
        format.html { 
          @title = "Edit User"
          render :action => "edit" 
        }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  def destroy
    @user = current_resource
    if !current_user?(@user)
      @user.destroy
      flash[:success] = "User remove."
    else
      flash[:error] = "Cannot remove yourself."
    end
    redirect_to users_path
  end

  private
  
  def current_resource
    if params[:action] == 'create'
      @current_resource ||= params[:user] if params[:user]
    else
      @current_resource ||= User.find(params[:id]) if params[:id]
    end
  end
  
  def sort_column
    super(User.column_names + ['departments.display_name'], 'name')
  end
  
end
