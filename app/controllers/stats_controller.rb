class StatsController < ApplicationController
  authorize_resource :class => StatsController
  
  def index
    @department = current_user.department
    @sites = @department.sites
    @title = "Statistics"
    @client_types = Hash["mac", "Macs", "pc", "PCs", "tc", "Thin Clients", "zc", "Zero Clients"]
  end

  def show
    case params[:chart_select]
      when "total" 
        total(params)
        subselect = "_#{params[:total_subselect].tr('-', '_')}"
      when "average"
        average(params)
        subselect = "_#{params[:average_subselect].tr('-', '_')}"
      when "concurrent"
        concurrent(params)
        subselect = "_#{params[:concurrent_subselect].tr('-', '_')}"
      when "historical_snapshots"
        historical_snapshots(params)
        subselect = ""
    end
    tmpl = "stats/charts/#{params[:chart_select]}#{subselect}"
    render tmpl, :formats => [:js]
  end
  
  private
  
  def total(options)
    send("total_#{options[:total_subselect].tr('-', '_')}", options)
  end
  
  def total_per_site(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Log.total_per_site(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    if @chart_type == "pie"
      @total = @data.values.inject(0){|sum, i| sum += i}
      percentages = Hash.new
      @data.each{|k,v| percentages[k] = ((v.to_f/@total) * 100).round(1)}
      @data = percentages.to_a
    end 
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def total_per_year(options)
    department = current_user.department
    sites = department.sites.pluck(:id)
    @data = Log.total_per_year(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    if @chart_type == "pie"
      @total = @data.values.inject(0){|sum, i| sum += i}
      percentages = Hash.new
      @data.each{|k,v| percentages[k] = ((v.to_f/@total) * 100).round(1)}
      @data = percentages.to_a
    end
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def total_per_month(options)
    department = current_user.department
    sites = department.sites.pluck(:id)
    @data = Log.total_per_month(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    if @chart_type == "pie"
      @total = @data.values.inject(0){|sum, i| sum += i}
      percentages = Hash.new
      @data.each{|k,v| percentages[k] = ((v.to_f/@total) * 100).round(1)}
      @data = percentages.to_a
    end
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def total_per_month_and_site(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Log.total_per_month_and_site(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    @subtitle = "Per Site"
    date_subtitle = format_date_subtitle(options[:start_date], options[:end_date])
    @subtitle = @subtitle + ", " + date_subtitle unless date_subtitle.empty?
  end
  
  def total_per_week(options)
    department = current_user.department
    sites = department.sites.pluck(:id)
    @data = Log.total_per_week(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    if @chart_type == "pie"
      @total = @data.values.inject(0){|sum, i| sum += i}
      percentages = Hash.new
      @data.each{|k,v| percentages[k] = ((v.to_f/@total) * 100).round(1)}
      @data = percentages.to_a
    end
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def total_per_week_and_site(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Log.total_per_week_and_site(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    @subtitle = "Per Site"
    date_subtitle = format_date_subtitle(options[:start_date], options[:end_date])
    @subtitle = @subtitle + ", " + date_subtitle unless date_subtitle.empty?
  end
  
  def total_per_day(options)
    department = current_user.department
    sites = department.sites.pluck(:id)
    @data = Log.total_per_day(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    if @chart_type == "pie"
      @total = @data.values.inject(0){|sum, i| sum += i}
      percentages = Hash.new
      @data.each{|k,v| percentages[k] = ((v.to_f/@total) * 100).round(1)}
      @data = percentages.to_a
    end
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def total_per_day_and_site(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Log.total_per_day_and_site(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    @subtitle = "Per Site"
    date_subtitle = format_date_subtitle(options[:start_date], options[:end_date])
    @subtitle = @subtitle + ", " + date_subtitle unless date_subtitle.empty?
  end
  
  def total_per_hour(options)
    department = current_user.department
    sites = department.sites.pluck(:id)
    @data = Log.total_per_hour(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    if @chart_type == "pie"
      @total = @data.values.inject(0){|sum, i| sum += i}
      percentages = Hash.new
      @data.each{|k,v| percentages[k] = ((v.to_f/@total) * 100).round(1)}
      @data = percentages.to_a
    end
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def total_per_hour_and_site(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Log.total_per_hour_and_site(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    @subtitle = "Per Site"
    date_subtitle = format_date_subtitle(options[:start_date], options[:end_date])
    @subtitle = @subtitle + ", " + date_subtitle unless date_subtitle.empty?
  end
  
  def average(options)
    send("average_#{options[:average_subselect]}", options)
  end
  
  def average_daily(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Log.average_daily(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    if @chart_type == "pie"
      @total = @data.values.inject(0){|sum, i| sum += i}
      percentages = Hash.new
      @data.each{|k,v| percentages[k] = ((v.to_f/@total) * 100).round(1)}
      @data = percentages.to_a
    end
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def average_weekly(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Log.average_weekly(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    if @chart_type == "pie"
      @total = @data.values.inject(0){|sum, i| sum += i}
      percentages = Hash.new
      @data.each{|k,v| percentages[k] = ((v.to_f/@total) * 100).round(1)}
      @data = percentages.to_a
    end
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def average_monthly(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Log.average_monthly(sites, options[:start_date], options[:end_date], options[:client_type_select])
    @chart_type = options[:type_select]
    if @chart_type == "pie"
      @total = @data.values.inject(0){|sum, i| sum += i}
      percentages = Hash.new
      @data.each{|k,v| percentages[k] = ((v.to_f/@total) * 100).round(1)}
      @data = percentages.to_a
    end
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def concurrent(options)
    send("concurrent_#{options[:concurrent_subselect].tr('-', '_')}", options)
  end
  
  def concurrent_average_overall(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Snapshot.concurrent_average_overall(sites, options[:start_date], options[:end_date])
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def concurrent_average_per_site(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Snapshot.concurrent_average_per_site(sites, options[:start_date], options[:end_date])
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def concurrent_maximum_overall(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Snapshot.concurrent_maximum_overall(sites, options[:start_date], options[:end_date])
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def concurrent_maximum_per_site(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Snapshot.concurrent_maximum_per_site(sites, options[:start_date], options[:end_date])
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
  end
  
  def historical_snapshots(options)
    department = current_user.department
    sites = options[:site_select].include?("all") ? department.sites.pluck(:id) : department.sites.where(:short_name => options[:site_select]).pluck(:id)
    @data = Snapshot.historical_snapshots(sites, options[:start_date], options[:end_date])
    @subtitle = format_date_subtitle(options[:start_date], options[:end_date])
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
