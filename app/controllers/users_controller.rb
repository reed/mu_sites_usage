class UsersController < ApplicationController
  load_and_authorize_resource
  
  def index
    @title = "#{current_user.department.display_name} Users"
  end

  def new
    @title = "New User"
  end

  def create
    @department = current_user.department
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
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "User updated."
      redirect_to users_path
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if !current_user?(@user)
      @user.destroy
      flash[:success] = "User destroyed."
    else
      flash[:error] = "Cannot destroy yourself."
    end
    redirect_to users_path
  end

end
