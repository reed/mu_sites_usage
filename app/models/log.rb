class Log < ActiveRecord::Base
  attr_accessible :client_id, :operation, :login_time, :logout_time, :user_id, :vm
  
  validates :client_id, :presence => :true
  validates :operation, :presence => :true,
                      :inclusion => { :in => ["login", "logout"] }
                      
  belongs_to :client
  
  #default_scope order('updated_at DESC')
  
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
      s = s.by_date(filters[:start_date], filters[:end_date])
      if filters[:site]
         s = s.where("clients.site_id" => filters[:site])
      end
      s
    else
      includes(:client => :site)
    end
  end
  
  def self.total_logins_per_site(site_ids, start_date = nil, end_date = nil, client_types = ["all"])
    initial_hash = Hash.new
    Site.where(:id => site_ids).pluck(:display_name).each{|d| initial_hash[d] = 0 }
    data = includes(:client => :site).where('clients.site_id' => site_ids).by_date(start_date, end_date)
    
    unless client_types.include? "all"
      data = data.where('clients.client_type' => client_types)
    end
    
    data = data.group('sites.display_name').order('sites.display_name').count
    initial_hash.merge(data)
  end
  
  def self.total_logins_per_year(site_ids, start_date = nil, end_date = nil, client_types = ["all"])
    data = includes(:client).where('clients.site_id' => site_ids)
    unless client_types.include? "all"
      data = data.where('clients.client_type' => client_types)
    end
    data = data.by_date(start_date, end_date).group('YEAR(DATEADD(hour, -6, login_time))').order('YEAR(DATEADD(hour, -6, login_time))').count
    s_data = Hash.new
    data.each{|k,v| s_data[k.to_s] = v}
    s_data
  end
  
  #Log.group('CAST(DATEADD(hour, -6, login_time) as date)').count
end
