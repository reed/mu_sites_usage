class Department < ActiveRecord::Base
  extend FriendlyId
  friendly_id :short_name
  
  attr_accessible :display_name, :short_name
  
  short_name_regex = /\A[a-z0-9]*\z/
  
  validates :display_name, :presence => true
  validates :short_name, :presence => true, 
                         :uniqueness => { :case_sensitive => false },
                         :format => { :with => short_name_regex }
                         
  has_many :sites, :dependent => :destroy
  #has_many :clients, :through => :sites
  has_many :users, :dependent => :destroy
  
  def client_count(type)
    c = Client.enabled
    case type
    when "windows"
      c = c.windows
    when "macs", "mac"
      c = c.macs
    when "thinclients", "tc"
      c = c.thinclients
    when "pcs", "pc"
      c = c.pcs
    else
      return 0
    end
    c.includes(:site).where("sites.department_id" => id).count
  end
  
  def status_count
    counts = { available: 0, unavailable: 0, offline: 0 }
    statuses = Client.enabled.includes(:site).where("sites.department_id" => id).group('current_status').count
    statuses = counts.merge(Hash[statuses.map{|k,v| [k.to_sym, v]}])
  end
end
