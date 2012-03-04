class Snapshot < ActiveRecord::Base
  attr_accessible :site_id, :day, :time_increment, :available, :unavailable, :offline
  
  validates :site_id, :presence => :true
  validates :day, :presence => :true
  validates :time_increment, :presence => :true
  
  belongs_to :site
  
  before_validation :generate_day_and_time_increment
  
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
