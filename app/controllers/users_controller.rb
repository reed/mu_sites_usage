class UsersController < ApplicationController
  load_and_authorize_resource
  helper_method :sort_column, :sort_direction
  
  def index
    @title = "#{current_user.department.display_name} Users"
    @users = @users.order(sort_column + " " + sort_direction).page(params[:page])
  end

  def new
    @title = "New User"
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
    @title = "Edit user"
  end
  
  def update
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
    @user = User.find(params[:id])
    if !current_user?(@user)
      @user.destroy
      flash[:success] = "User remove."
    else
      flash[:error] = "Cannot remove yourself."
    end
    redirect_to users_path
  end

  private
  
  def sort_column
    (User.column_names + ["departments.display_name"]).include?(params[:sort]) ? params[:sort] : "username"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
