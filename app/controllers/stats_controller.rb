class StatsController < ApplicationController
  authorize_resource :class => StatsController
  def index
    @department = current_user.department
    @sites = @department.sites
  end

  def show
    case params[:chart_select]
    when "total-logins" 
      total_logins(params)
    end
  end
  
  private
  
  def total_logins(options)
    case options[:total_subselect]
    when "per-site" 
      total_logins_per_site(options)
    when "per-year" 
      total_logins_per_year(options)
    when "per-month" 
      total_logins_per_month(options)
    when "per-month-and-site" 
      total_logins_per_month_and_site(options)
    when "per-week" 
      total_logins_per_week(options)
    when "per-week-and-site" 
      total_logins_per_week_and_site(options)
    when "per-day" 
      total_logins_per_day(options)
    when "per-day-and-site" 
      total_logins_per_day_and_site(options)
    when "per-hour" 
      total_logins_per_hour(options)
    when "per-hour-and-site" 
      total_logins_per_hour_and_site(options)
    end
  end
  
  def total_logins_per_site(options)
    @department = current_user.department
    if options[:site_select].include? "all"
      @sites = @department.sites
    else
      @sites = @department.sites.where(:short_name => options[:site_select])
    end
    @data = Hash.new
    @sites.all.each do |site|
      @data[site.display_name] = Log.total_logins_per_site(site.id)
    end
    render 'total_logins_per_site', :formats => [:json]
  end
  
  def total_logins_per_year(options)
  end
  
  def total_logins_per_month(options)
  end
  
  def total_logins_per_month_and_site(options)
  end
  
  def total_logins_per_week(options)
  end
  
  def total_logins_per_week_and_site(options)
  end
  
  def total_logins_per_day(options)
  end
  
  def total_logins_per_day_and_site(options)
  end
  
  def total_logins_per_hour(options)
  end
  
  def total_logins_per_hour_and_site(options)
  end
end
