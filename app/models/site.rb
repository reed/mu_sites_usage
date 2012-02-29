class Site < ActiveRecord::Base
  extend FriendlyId
  friendly_id :short_name
  
  attr_accessible :display_name, :short_name, :name_filter, :enabled, :site_type, :department_id
  
  short_name_regex = /\A[a-z0-9]*\z/
  
  TYPES = %w[general_access classroom residence_hall laptop_checkout]
  
  validates :display_name, :presence => true
  validates :short_name, :presence => true, 
                         :uniqueness => { :case_sensitive => false },
                         :format => { :with => short_name_regex }
  validates :name_filter, :presence => true
  validates :department_id, :presence => true
  validates :site_type, :presence => true,
                        :inclusion => { :in => TYPES }
  
  scope :enabled, where(:enabled => true)
  default_scope order('display_name ASC')
  
  belongs_to :department
  has_many :clients, :dependent => :nullify
  
  def self.match_name_with_site(name)
    name.upcase!
    concat_operator = ENV['RAILS_ENV'] == "production" ? "+" : "||"
    where(["? LIKE (name_filter #{concat_operator} '%')", name]).first
  end
  
  def self.refilter_clients
    Client.recheck_sites
  end
  
  # def self.total_logins_per_site(site_ids, start_date = nil, end_date = nil)
  #   initial_hash = Hash.new
  #   where(:id => site_ids).pluck(:display_name).each{|d| initial_hash[d] = 0 }
  #   #data = where(:id => site_ids).joins("LEFT OUTER JOIN clients on clients.site_id = sites.id LEFT OUTER JOIN logs on logs.client_id = clients.id")
  #   data = includes(:client => :site).where('clients.site_id' => site_ids)
  #   if start_date.present? && end_date.present?
  #     formatted_start = DateTime.strptime(start_date + " CST", "%m/%d/%Y %Z").utc.strftime("%F %T")
  #     formatted_end = (DateTime.strptime(end_date + " CST", "%m/%d/%Y %Z").utc + 1.day).strftime("%F %T")
  #     data = data.where('logs.login_time' => formatted_start..formatted_end)
  #   elsif start_date.present?
  #     data = data.where("logs.login_time >= ?", DateTime.strptime(start_date + " CST", "%m/%d/%Y %Z").utc.strftime("%F %T"))
  #   elsif end_date.present?
  #     data = data.where("logs.login_time <= ?", (DateTime.strptime(end_date + " CST", "%m/%d/%Y %Z").utc + 1.day).strftime("%F %T"))
  #   else
  #     data = data.where("logs.login_time <= ?", Time.zone.now.utc.strftime("%F %T"))
  #   end
  #   #data = data.group(:display_name).count
  #   data = data.group('sites.display_name').order('sites.display_name').count
  #   initial_hash.merge(data)
  # end
  
  def client_count(type)
    case type
    when "windows"
      clients.enabled.windows.count
    when "macs", "mac"
      clients.enabled.macs.count
    when "thinclients", "tc"
      clients.enabled.thinclients.count
    when "pcs", "pc"
      clients.enabled.pcs.count
    else
      0
    end
  end
  
  def status_count(status, type = "all")
    case type
    when "all"
      clients.enabled.where(:current_status => status).count
    when "pcs", "pc"
      clients.enabled.pcs.where(:current_status => status).count
    when "tcs", "tc"
      clients.enabled.thinclients.where(:current_status => status).count
    when "macs", "mac"
      clients.enabled.macs.where(:current_status => status).count
    else
      0
    end
  end
  
  def status_counts_by_type
    counts = Hash.new
    [:pc, :tc, :mac].each do |type|
      counts[type] = {
        :total => client_count(type.to_s),
        :available => status_count('available', type.to_s),
        :unavailable => status_count('unavailable', type.to_s),
        :offline => status_count('offline', type.to_s)
      }
    end
    counts
  end
  
end
