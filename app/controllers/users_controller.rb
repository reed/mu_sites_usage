class UsersController < ApplicationController
  def index
    @title = "All users"
    @users = User.all
  end

  def new
    @user = User.new
    @title = "New User"
  end

  def create
    @department = Department.first #to be changed
    @user = @department.users.build(params[:user]) 
    if @user.save
      #sign_in @user
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
    #if !current_user?(@user)
      @user.destroy
      flash[:success] = "User destroyed."
    #else
    #  flash[:error] = "Cannot destroy yourself."
    #end
    redirect_to users_path
  end

end
