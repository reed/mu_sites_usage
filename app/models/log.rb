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
      if filters[:name]
        s = s.where("clients.name LIKE ?", "%#{filters[:name]}%")
      end
      if filters[:start_date] && filters[:end_date]
        s = s.where(:login_time => DateTime.strptime(filters[:start_date], "%m/%d/%Y").utc..DateTime.strptime(filters[:end_date], "%m/%d/%Y").utc)
      elsif filters[:start_date]
        s = s.where("login_time >= ?", DateTime.strptime(filters[:start_date], "%m/%d/%Y").utc)
      elsif filters[:end_date]
        s = s.where("login_time <= ?", DateTime.strptime(filters[:end_date], "%m/%d/%Y").utc)
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
