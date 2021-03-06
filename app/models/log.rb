class Log < ActiveRecord::Base
  
  ip_regex = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/
  
  validates :client_id, :presence => :true
  validates :operation, :presence => :true,
                      :inclusion => { :in => ["login", "logout"] }
  validates :vm_ip_address, :format => { :with => ip_regex }
                      
  belongs_to :client
  
  def self.by_date(s, e)
    f_s = DateTime.strptime(s + " CST", "%m/%d/%Y %Z").utc.strftime("%F %T") if s.present?
    f_e = (DateTime.strptime(e + " CST", "%m/%d/%Y %Z").utc + 1.day).strftime("%F %T") if e.present?
    if s.present? && e.present?
      where(:login_time => f_s..f_e)
    elsif s.present?
      where("login_time >= ?", f_s)
    elsif e.present?
      where("login_time <= ?", f_e)
    else
      scoped
    end
  end
  
  def self.with_sites(site_ids)
    where('clients.site_id' => site_ids)
  end
  
  def self.with_client_types(types = ["all"])
    types.include?("all") ? scoped : where('clients.client_type' => types)
  end
  
  def self.tokens(query)
    vms = where("vm LIKE ?", "#{query}%").pluck(:vm).uniq.sort
    users = where("user_id LIKE ?", "#{query}%").pluck(:user_id).uniq.sort
    tokens = vms.collect { |vm| {:id => vm, :category => 'vm' }}
    tokens += users.collect { |user| {:id => user, :category => 'user' }}
  end
  
  def self.search(filters)
    if filters
      s = includes(:client => :site)
      s = s.where(:client_id => filters[:client]) if filters[:client]
      s = s.where(:vm => filters[:vm]) if filters[:vm]
      s = s.where(:user_id => filters[:user]) if filters[:user]
      s = s.by_date(filters[:start_date], filters[:end_date])
      s = s.where("clients.site_id" => filters[:site]) if filters[:site]
      s = s.where("clients.client_type" => filters[:client_type]) if filters[:client_type]
      s
    else
      includes(:client => :site)
    end
  end
  
  def self.total_per_site(site_ids, start_date = nil, end_date = nil, client_types)
    initial_hash = Hash.new
    Site.where(:id => site_ids).pluck(:display_name).each{|d| initial_hash[d] = 0 }
    data = includes(:client => :site)
              .with_sites(site_ids)
              .by_date(start_date, end_date)
              .with_client_types(client_types)
              .group('sites.display_name')
              .order('sites.display_name')
              .count
    initial_hash.merge(data)
  end
  
  def self.total_per_year(site_ids, start_date = nil, end_date = nil, client_types)
    data = includes(:client)
            .with_sites(site_ids)
            .with_client_types(client_types)
            .by_date(start_date, end_date)
            .group('YEAR(DATEADD(hour, -6, login_time))')
            .order('YEAR(DATEADD(hour, -6, login_time))')
            .count
    s_data = Hash.new
    data.each{|k,v| s_data[k.to_s] = v}
    s_data
  end
  
  def self.total_per_semester(site_ids, start_date = nil, end_date = nil, client_types)
    data = includes(:client => :site)
            .with_sites(site_ids)
            .with_client_types(client_types)
            .by_date(start_date, end_date)
            .group("DATENAME(yyyy, DATEADD(hour, -6, login_time)) + ' ' + DATENAME(wk, DATEADD(hour, -6, login_time))")
            .order("DATENAME(yyyy, DATEADD(hour, -6, login_time)) + ' ' + DATENAME(wk, DATEADD(hour, -6, login_time))")
            .count
    
    s_data = Hash.new
    data.sort_by{|i| Date.strptime(i[0], '%Y %U') }.each do |i|
      semester = Utilities::DateFormatters.semester(i[0])
      if s_data.has_key? semester
        s_data[semester] += i[1]
      else
        s_data[semester] = i[1]
      end
    end
    s_data
  end
  
  def self.total_per_semester_and_site(site_ids, start_date = nil, end_date = nil, client_types)
    data = includes(:client => :site)
            .with_sites(site_ids)
            .with_client_types(client_types)
            .by_date(start_date, end_date)
            .group("DATENAME(yyyy, DATEADD(hour, -6, login_time)) + ' ' + DATENAME(wk, DATEADD(hour, -6, login_time))", "sites.display_name")
            .order("sites.display_name", "DATENAME(yyyy, DATEADD(hour, -6, login_time)) + ' ' + DATENAME(wk, DATEADD(hour, -6, login_time))")
            .count
            
    weeks = data.keys.collect{|x| x[0]}.uniq.sort_by{|x| Date.strptime(x, '%Y %U')}
    semesters = weeks.map{|week| Utilities::DateFormatters.semester(week)}.uniq
    sites = data.keys.collect{|x| x[1]}.uniq
    f_data = Array.new
    sites.each do |s|
      d = Array.new(semesters.count).fill(0)
      weeks.each_with_index do |w, i|
        semester_index = semesters.index Utilities::DateFormatters.semester(w)
        d[semester_index] += data[[w, s]] if data.has_key?([w, s]) 
      end
      f_data << {"name" => s, "data" => d}
    end
    {:categories => semesters, :sites => f_data}
  end
  
  def self.total_per_month(site_ids, start_date = nil, end_date = nil, client_types)
    data = includes(:client)
            .with_sites(site_ids)
            .with_client_types(client_types)
            .by_date(start_date, end_date)
            .group("CONVERT(VARCHAR(7), DATEADD(hour, -6, login_time), 120)")
            .order("CONVERT(VARCHAR(7), DATEADD(hour, -6, login_time), 120)")
            .count
            
    s_data = Hash.new
    data.each{|k,v| s_data[Utilities::DateFormatters.month(k)] = v}
    s_data
  end
  
  def self.total_per_month_and_site(site_ids, start_date = nil, end_date = nil, client_types)
    data = includes(:client => :site)
            .with_sites(site_ids)
            .with_client_types(client_types)
            .by_date(start_date, end_date)
            .group("CONVERT(VARCHAR(7), DATEADD(hour, -6, login_time), 120)", "sites.display_name")
            .order("sites.display_name", "CONVERT(VARCHAR(7), DATEADD(hour, -6, login_time), 120)")
            .count
    
    months = data.keys.collect{|x| x[0]}.uniq
    sites = data.keys.collect{|x| x[1]}.uniq
    f_data = Array.new
    sites.each do |s|
      d = Array.new(months.count).fill(0)
      months.each_with_index do |m, i|
        d[i] = data[[m, s]] if data.has_key?([m, s])
      end
      f_data << {"name" => s, "data" => d}
    end
    months.collect!{|m| Utilities::DateFormatters.month(m)}
    {:categories => months, :sites => f_data}
  end
  
  def self.total_per_week(site_ids, start_date = nil, end_date = nil, client_types)
    data = includes(:client => :site)
            .with_sites(site_ids)
            .with_client_types(client_types)
            .by_date(start_date, end_date)
            .group("DATENAME(yyyy, DATEADD(hour, -6, login_time)) + ' ' + DATENAME(wk, DATEADD(hour, -6, login_time))")
            .order("DATENAME(yyyy, DATEADD(hour, -6, login_time)) + ' ' + DATENAME(wk, DATEADD(hour, -6, login_time))")
            .count
    Rails.logger.info data
    s_data = Hash.new
    data.sort_by{|i| Date.strptime(i[0], '%Y %U') }.each{|i| s_data[Utilities::DateFormatters.week(i[0])] = i[1]}
    s_data
  end
  
  def self.total_per_week_and_site(site_ids, start_date = nil, end_date = nil, client_types)
    data = includes(:client => :site)
            .with_sites(site_ids)
            .with_client_types(client_types)
            .by_date(start_date, end_date)
            .group("DATENAME(yyyy, DATEADD(hour, -6, login_time)) + ' ' + DATENAME(wk, DATEADD(hour, -6, login_time))", "sites.display_name")
            .order("sites.display_name", "DATENAME(yyyy, DATEADD(hour, -6, login_time)) + ' ' + DATENAME(wk, DATEADD(hour, -6, login_time))")
            .count
            
    weeks = data.keys.collect{|x| x[0]}.uniq.sort_by{|x| Date.strptime(x, '%Y %U')}
    sites = data.keys.collect{|x| x[1]}.uniq
    f_data = Array.new
    sites.each do |s|
      d = Array.new(weeks.count).fill(0)
      weeks.each_with_index{|w, i| d[i] = data[[w, s]] if data.has_key?([w, s]) }
      f_data << {"name" => s, "data" => d}
    end
    
    weeks.collect!{|w| Utilities::DateFormatters.week(w)}
    {:categories => weeks, :sites => f_data}
  end
  
  def self.total_per_day(site_ids, start_date = nil, end_date = nil, client_types)
    data = includes(:client => :site)
            .with_sites(site_ids)
            .with_client_types(client_types)
            .by_date(start_date, end_date)
            .group("CONVERT(VARCHAR(10), DATEADD(hour, -6, login_time), 120)")
            .order("CONVERT(VARCHAR(10), DATEADD(hour, -6, login_time), 120)")
            .count
    s_data = Hash.new
    data.each{|k,v| s_data[Utilities::DateFormatters.day(k)] = v}
    s_data
  end
  
  def self.total_per_day_and_site(site_ids, start_date = nil, end_date = nil, client_types)
    data = includes(:client => :site)
            .with_sites(site_ids)
            .with_client_types(client_types)
            .by_date(start_date, end_date)
            .group("CONVERT(VARCHAR(10), DATEADD(hour, -6, login_time), 120)", "sites.display_name")
            .order("sites.display_name", "CONVERT(VARCHAR(10), DATEADD(hour, -6, login_time), 120)")
            .count
      
    days = data.keys.collect{|x| x[0]}.uniq
    sites = data.keys.collect{|x| x[1]}.uniq
    f_data = Array.new
    sites.each do |s|
      d = Array.new(days.count).fill(0)
      days.each_with_index do |day, i|
        d[i] = data[[day, s]] if data.has_key?([day, s])
      end
      f_data << {"name" => s, "data" => d}
    end
    days.collect!{|d| Utilities::DateFormatters.day(d)}
    {:categories => days, :sites => f_data}
  end
  
  def self.total_per_hour(site_ids, start_date = nil, end_date = nil, client_types)
    data = includes(:client => :site)
            .with_sites(site_ids)
            .with_client_types(client_types)
            .by_date(start_date, end_date)
            .group("CONVERT(VARCHAR(2), DATEADD(hour, -6, login_time), 108)")
            .order("CONVERT(VARCHAR(2), DATEADD(hour, -6, login_time), 108)")
            .count
    s_data = Hash.new
    hours = ("00".."23").to_a
    hours.each{|h| s_data[Utilities::DateFormatters.hour(h)] = data[h] || 0}
    s_data
  end
  
  def self.total_per_hour_and_site(site_ids, start_date = nil, end_date = nil, client_types)
    Rails.logger.info "client_types: #{client_types}"
    data = includes(:client => :site)
            .with_sites(site_ids)
            .with_client_types(client_types)
            .by_date(start_date, end_date)
            .group("CONVERT(VARCHAR(2), DATEADD(hour, -6, login_time), 108)", "sites.display_name")
            .order("sites.display_name", "CONVERT(VARCHAR(2), DATEADD(hour, -6, login_time), 108)")
            .count
            
    hours = ("00".."23").to_a
    sites = data.keys.collect{|x| x[1]}.uniq
    f_data = Array.new
    sites.each do |s|
      d = Array.new(hours.count).fill(0)
      hours.each_with_index do |hour, i|
        d[i] = data[[hour, s]] if data.has_key?([hour, s])
      end
      f_data << {"name" => s, "data" => d}
    end
    hours.collect!{|h| Utilities::DateFormatters.hour(h)}
    {:categories => hours, :sites => f_data}
  end

  def self.average_daily(site_ids, start_date = nil, end_date = nil, client_types)
    time_to_day = "CONVERT(VARCHAR(10), DATEADD(hour, -6, login_time), 120)"
    filtered = includes(:client => :site)
                  .with_sites(site_ids)
                  .with_client_types(client_types)
                  .by_date(start_date, end_date)
                  
    data = filtered
            .group(time_to_day, "sites.display_name")
            .order("sites.display_name", time_to_day)
            .count
    
    first_days = filtered
                  .group("sites.display_name")
                  .minimum(time_to_day)
                    
    last_days = filtered
                  .group("sites.display_name")
                  .maximum(time_to_day)
                          
    days = data.keys.collect{|x| x[0]}.uniq
    sites = data.keys.collect{|x| x[1]}.uniq
    f_data = Hash.new
    sites.each do |s|
      total = 0
      days.each_with_index do |day, i|
        total += data[[day, s]] if data.has_key?([day, s])
      end
      f_data[s] = (total / Utilities::DateCalculations.days_between(first_days[s], last_days[s]))
    end
    f_data
  end
  
  def self.average_weekly(site_ids, start_date = nil, end_date = nil, client_types)
    time_to_day = "CONVERT(VARCHAR(10), DATEADD(hour, -6, login_time), 120)"
    time_to_week = "DATENAME(yyyy, DATEADD(hour, -6, login_time)) + ' ' + DATENAME(wk, DATEADD(hour, -6, login_time))"
    filtered = includes(:client => :site)
                  .with_sites(site_ids)
                  .with_client_types(client_types)
                  .by_date(start_date, end_date)
                  
    data = filtered
            .group(time_to_week, "sites.display_name")
            .order("sites.display_name", time_to_week)
            .count
    
    first_days = filtered
                  .group("sites.display_name")
                  .minimum(time_to_day)
                    
    last_days = filtered
                  .group("sites.display_name")
                  .maximum(time_to_day)
                          
    weeks = data.keys.collect{|x| x[0]}.uniq
    sites = data.keys.collect{|x| x[1]}.uniq
    f_data = Hash.new
    sites.each do |s|
      total = 0
      weeks.each_with_index do |week, i|
        total += data[[week, s]] if data.has_key?([week, s])
      end
      week_count = (Utilities::DateCalculations.days_between(first_days[s], last_days[s]) / 7.0).ceil
      f_data[s] = (total / week_count)
    end
    f_data
  end
  
  def self.average_monthly(site_ids, start_date = nil, end_date = nil, client_types)
    time_to_month = "CONVERT(VARCHAR(7), DATEADD(hour, -6, login_time), 120)"
    data = includes(:client => :site)
              .with_sites(site_ids)
              .with_client_types(client_types)
              .by_date(start_date, end_date)
              .group(time_to_month, "sites.display_name")
              .order("sites.display_name", time_to_month)
              .count
               
    months = data.keys.collect{|x| x[0]}.uniq
    sites = data.keys.collect{|x| x[1]}.uniq
    f_data = Hash.new
    sites.each do |s|
      total = 0
      month_count = 0
      months.each_with_index do |month, i|
        if data.has_key?([month, s])
          total += data[[month, s]] 
          month_count += 1
        end
      end
      f_data[s] = (total / month_count)
    end
    f_data
  end
  
end
