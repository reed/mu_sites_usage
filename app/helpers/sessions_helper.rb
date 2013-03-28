module SessionsHelper
  def sign_in(user)
    user.increment!(:logins)
    session[:user_id] = user.id
    current_user = user
  end

  def sign_out
    session[:user_id] = nil
    current_user = nil
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    !current_user.nil?
  end

  def deny_access
    store_location
    if signed_in?
      redirect_to root_url, :flash => { :error => 'Not Authorized' }
    else
      redirect_to login_path, :flash => { :error => "Please sign in to access this page." }
    end
  end

  def current_user?(user)
    user == current_user
  end
  
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
  
  private 
  
  def store_location
    session[:return_to] = request.fullpath
  end

  def clear_return_to
    session[:return_to] = nil
  end
end
