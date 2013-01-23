class ApiController < ApplicationController
  
  def index
    @title = "API"
    @departments = Department.all
    render 'api'
  end
  
  def sites
    if params[:sites].present?
      @sites = SiteDecorator.decorate(Site.enabled.where(:short_name => params[:sites].split('/')).order(:display_name))
    end
    render 'sites', formats: [:json]
  end
  
  def sites_list
    if params[:department].present? and Department.exists? params[:department]
      @sites = Department.find(params[:department]).sites.enabled.external.order(:display_name)
    else
      @sites = Site.enabled.external.order(:display_name)
    end
    render 'sites_index', formats: [:json]
  end
  
  def counts
    if Site.enabled.exists?(params[:id])
      site = Site.enabled.find(params[:id])
      render json: site.status_counts
    else
      render text: "error"
    end
  end
  
  def info
    if params[:ip].present?
      @client = Client.enabled.order(:last_checkin).find_by_ip_address(params[:ip])
      if @client
        if @client.logged_in?
          ldap = Ldap.new
          @username = ldap.get_display_name(@client.current_user)
          @email = ldap.get_email(@client.current_user)
        else
          last_log = @client.logs.last
          if last_log
            @user_id = last_log[:user_id]
            ldap = Ldap.new
            @username = ldap.get_display_name(@user_id)
            @email = ldap.get_email(@user_id)
            @last_logout = last_log[:logout_time]
          end
        end
        render 'info', formats: [:json] 
      else
        render text: "Device not found"
      end
    else
      render text: "error"
    end
  end
end
