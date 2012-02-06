class Site < ActiveRecord::Base
  extend FriendlyId
  friendly_id :short_name
  
  attr_accessible :display_name, :short_name, :name_filter, :department_id
  
  short_name_regex = /\A[a-z0-9]*\z/
  
  validates :display_name, :presence => true
  validates :short_name, :presence => true, 
                         :uniqueness => { :case_sensitive => false },
                         :format => { :with => short_name_regex }
  validates :name_filter, :presence => true
  validates :department_id, :presence => true
  
  belongs_to :department
  has_many :clients
  
  def self.match_name_with_site(name)
    name.upcase!
    where(["? LIKE (name_filter || '%')", name]).first
  end
  
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
