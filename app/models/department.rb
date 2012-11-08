class Department < ActiveRecord::Base
  extend FriendlyId
  friendly_id :short_name
  
  short_name_regex = /\A[a-z0-9]*\z/
  
  validates :display_name, :presence => true
  validates :short_name, :presence => true, 
                         :uniqueness => { :case_sensitive => false },
                         :format => { :with => short_name_regex }
                         
  has_many :sites, :dependent => :destroy
  has_many :users, :dependent => :destroy
  
  after_save :expire_department_list_cache
  
  def client_count(type)
    c = Client.enabled.includes(:site).where('sites.department_id' => id).group(:client_type).count
    types = case type
            when "windows"
              Client::WINDOWS_TYPES
            when "macs", "mac"
              Client::MAC_TYPES
            when "thinclients", "tc"
              Client::THINCLIENT_TYPES
            when "pcs", "pc"
              Client::PC_TYPES
            else
              []
            end
    c.slice(*types).values.reduce(:+) || 0
  end
  
  def status_counts
    counts = { available: 0, unavailable: 0, offline: 0 }
    statuses = Client.enabled.includes(:site).where("sites.department_id" => id).group('current_status').count
    statuses = counts.merge(Hash[statuses.map{|k,v| [k.to_sym, v]}])
  end
  
  def site_type_counts
    sites.unscoped.enabled.group(:site_type).count
  end
  
  private
  
  def expire_department_list_cache
    Rails.cache.delete 'department_list'
  end
end
