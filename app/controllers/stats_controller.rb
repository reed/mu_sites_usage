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
    department = current_user.department
    if options[:site_select].include? "all"
      sites = department.sites.pluck(:id)
    else
      sites = department.sites.where(:short_name => options[:site_select]).pluck(:id)
    end
    @data = Site.total_logins_per_site(sites, options[:start_date], options[:end_date])
    @chart_type = options[:type_select]
    if @chart_type == "pie"
      @total = @data.values.inject(0){|sum, i| sum += i}
      percentages = Hash.new
      @data.each{|k,v| percentages[k] = ((v.to_f/@total) * 100).round(1)}
      @data = percentages.to_a
    end 
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
    render 'total_logins_per_site', :formats => [:js]
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
  
  def format_date_subtitle(start_date = nil, end_date = nil)
    f_start = DateTime.strptime(start_date, "%m/%d/%Y") if start_date.present?
    f_end = DateTime.strptime(end_date, "%m/%d/%Y") if end_date.present?
    if start_date.present? && end_date.present?
      if start_date == end_date
        f_start.strftime("%b %e, %Y")
      elsif f_start.month == f_end.month && f_start.year == f_end.year
        f_start.strftime("%b %e - ") + f_end.strftime("%e, %Y")
      elsif f_start.year == f_end.year
        f_start.strftime("%b %e - ") + f_end.strftime("%b %e, %Y")
      else
        f_start.strftime("%b %e, %Y - ") + f_end.strftime("%b %e, %Y")
      end
    elsif start_date.present?
      f_start.strftime("Since %b %e, %Y")
    elsif end_date.present?
      f_end.strftime("Before %b %e, %Y")
    else
      ""
    end
  end
end
