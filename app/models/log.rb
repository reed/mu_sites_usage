class Log < ActiveRecord::Base
  attr_accessible :client_id, :operation, :login_time, :logout_time, :user_id, :vm
  
  validates :client_id, :presence => :true
  validates :operation, :presence => :true,
                      :inclusion => { :in => ["login", "logout"] }
                      
  belongs_to :client
  
  #default_scope order('updated_at DESC')
  
  def self.search(filters)
    if filters
      s = includes(:client => :site)
      if filters[:text]
        s = s.where("clients.name LIKE ? 
                      OR clients.mac_address LIKE ? 
                      OR clients.ip_address LIKE ? 
                      OR user_id LIKE ? 
                      OR vm LIKE ?", "%#{filters[:text]}%",
                                      "%#{filters[:text]}%",
                                      "%#{filters[:text]}%",
                                      "%#{filters[:text]}%",
                                      "%#{filters[:text]}%")
      end
      if filters[:start_date] && filters[:end_date]
        formatted_start = DateTime.strptime(filters[:start_date] + " CST", "%m/%d/%Y %Z").utc.strftime("%F %T")
        formatted_end = (DateTime.strptime(filters[:end_date] + " CST", "%m/%d/%Y %Z").utc + 1.day).strftime("%F %T")
        s = s.where(:login_time => formatted_start..formatted_end)
      elsif filters[:start_date]
        s = s.where("login_time >= ?", DateTime.strptime(filters[:start_date] + " CST", "%m/%d/%Y %Z").utc.strftime("%F %T"))
      elsif filters[:end_date]
        s = s.where("login_time <= ?", (DateTime.strptime(filters[:end_date] + " CST", "%m/%d/%Y %Z").utc + 1.day).strftime("%F %T"))
      end
      if filters[:site]
        s = s.where("clients.site_id" => filters[:site])
      end
      s
    else
      includes(:client => :site)
    end
  end
  
end
