class Snapshot < ActiveRecord::Base
  attr_accessible :site_id, :day, :time_increment, :available, :unavailable, :offline
  
  INCREMENTS = Utilities::DateCalculations.minute_increments(5)
  validates :site_id, :presence => :true
  validates :day, :presence => :true
  validates :time_increment, :presence => :true
  
  belongs_to :site
  
  before_validation :generate_day_and_time_increment
  
  def self.by_date(s, e)
    f_s = DateTime.strptime(s + " CST", "%m/%d/%Y %Z").utc.strftime("%F") if s.present?
    f_e = (DateTime.strptime(e + " CST", "%m/%d/%Y %Z").utc + 1.day).strftime("%F") if e.present?
    if s.present? && e.present?
      where(:day => f_s..f_e)
    elsif s.present?
      where("day >= ?", f_s)
    elsif e.present?
      where("day <= ?", f_e)
    else
      scoped
    end
  end
  
  def self.with_sites(site_ids)
    where('site_id' => site_ids)
  end
  
  def self.concurrent_average_overall(site_ids, start_date = nil, end_date = nil)
    filtered = with_sites(site_ids)
                  .by_date(start_date, end_date)
            
    data = filtered
            .group(:time_increment)
            .sum(:unavailable)
    
    formatted_day = "CONVERT(VARCHAR(10), day, 120)"
    first_day = filtered.minimum(formatted_day)
    last_day = filtered.maximum(formatted_day)
    
    day_count = Utilities::DateCalculations.days_between(first_day, last_day).to_f
    
    f_data = Hash.new
    data.each_pair do |increment, total|
      f_data[increment] = (total / day_count).round(2)
    end
    INCREMENTS.merge(f_data).values
  end
  
  def self.concurrent_average_per_site(site_ids, start_date = nil, end_date = nil)
    filtered = includes(:site)
                .with_sites(site_ids)
                .by_date(start_date, end_date)
            
    data = filtered
            .group('sites.display_name', :time_increment)
            .sum(:unavailable)
    
    formatted_day = "CONVERT(VARCHAR(10), day, 120)"
    first_days = filtered.group('sites.display_name').minimum(formatted_day)
    last_days = filtered.group('sites.display_name').maximum(formatted_day)
    
    sites = data.keys.collect{|x| x[0]}.uniq
    increments = data.keys.collect{|x| x[1]}.uniq
    
    s_data = Hash.new
    sites.each do |site|
      f_data = Hash.new
      day_count = Utilities::DateCalculations.days_between(first_days[site], last_days[site]).to_f
      increments.each do |increment|
        if data.has_key?([site, increment])
          f_data[increment] = (data[[site, increment]] / day_count).round(2)
        end
      end
      s_data[site] = INCREMENTS.merge(f_data).values
    end
    s_data
  end
  
  def self.concurrent_maximum_overall(site_ids, start_date = nil, end_date = nil)
    filtered = with_sites(site_ids)
                  .by_date(start_date, end_date)
            
    data = filtered
            .group(:day, :time_increment)
            .sum(:unavailable)
    
    increments = data.keys.collect{|x| x[1]}.uniq
    
    f_data = Hash.new
    increments.each do |increment|
      f_data[increment] = data.select{|k,v| k[1] == increment}.keys.collect{|x| data.fetch(x)}.max
    end
    INCREMENTS.merge(f_data).values
  end
  
  def self.concurrent_maximum_per_site(site_ids, start_date = nil, end_date = nil)
    filtered = includes(:site)
                  .with_sites(site_ids)
                  .by_date(start_date, end_date)
            
    data = filtered
            .group('sites.display_name', :day, :time_increment)
            .sum(:unavailable)
    
    sites = data.keys.collect{|x| x[0]}.uniq
    
    s_data = Hash.new
    sites.each do |site|
      increments = data.select{|k,v| k[0] == site}.keys.collect{|x| x[2]}.uniq
    
      f_data = Hash.new
      increments.each do |increment|
        f_data[increment] = data.select{|k,v| [k[0], k[2]] == [site, increment]}.keys.collect{|x| data.fetch(x) }.max
      end
      s_data[site] = INCREMENTS.merge(f_data).values
    end
    s_data
  end
  
  def self.historical_snapshots(site_ids, start_date = nil, end_date = nil)
    data = with_sites(site_ids)
            .by_date(start_date, end_date)
            .select('CONVERT(VARCHAR(10), day, 120) as formatted_day, time_increment, SUM(available) as total_available, SUM(unavailable) as total_unavailable, SUM(offline) as total_offline')
            .group('CONVERT(VARCHAR(10), day, 120)', :time_increment)
            .order('CONVERT(VARCHAR(10), day, 120)', :time_increment)
    
    s_date = {"Unavailable" => [], "Available" => [],  "Offline" => []}
    data.each do |snapshot|
      s_time = Utilities::DateFormatters.snapshot_time(snapshot.formatted_day, snapshot.time_increment).to_i * 1000
      s_date["Available"] << [s_time, snapshot.total_available]
      s_date["Unavailable"] << [s_time, snapshot.total_unavailable]
      s_date["Offline"] << [s_time, snapshot.total_offline]
    end
    s_date
  end
  
  private
  
  def generate_day_and_time_increment
    now = Time.now
    hour = now.hour.to_s
    min_interval = (now.min / 5) * 5
    min_interval = min_interval < 10 ? "0#{min_interval}" : min_interval.to_s
    self.day = now.to_date
    self.time_increment = hour + min_interval
  end
  
end
