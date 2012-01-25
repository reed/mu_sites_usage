class Client < ActiveRecord::Base
  attr_accessible :name, :mac_address, :client_type, :ip_address, :last_checkin, :last_login, 
                    :current_status, :current_user, :current_vm, :enabled, :site_id
  
  mac_regex = /\A[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}\z/
  ip_regex = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/
   
  validates :name, :presence => true,
                    :length => { :maximum => 25 },
                    :uniqueness => { :case_sensitive => false }
  validates :mac_address, :presence => true,
                          :length => { :is => 17 },
                          :format => { :with => mac_regex }
  validates :ip_address, :format => { :with => ip_regex }
  validates :client_type, :presence => true,
                          :inclusion => { :in => ["tc", "pc", "mac"] }
  validates :current_status, :inclusion => { :in => ["available", "unavailable", "offline"] }
  
  belongs_to :site    
  has_many :logs
  
  scope :stale, lambda { where('last_checkin < ?', 10.minutes.ago) }
  
  before_update :maintain_site
  
  def self.find_or_create(properties)
    properties.keep_if do |key| 
      [:name, :mac_address, :client_type, :ip_address].include?(key.to_sym) 
    end
    properties[:name].upcase!
    properties[:mac_address].downcase!
    properties[:client_type].downcase!
    
    client = find_by_name(properties[:name])
    if client.nil?
      update_all({:enabled => false}, :mac_address => properties[:mac_address])
      site = Site.match_name_with_site(properties[:name])
      if site.nil?
        Client.create!(properties)
      else
        site.clients.create!(properties)
      end
    else
      client.update_attributes(properties)
      client
    end
  end
  
  def self.check_statuses
    scoped_by_enabled(true).stale.each do |c|
      c.update_attributes!({:current_status => 'offline' })
    end
  end
  
  def record_action(operation)
    case operation.downcase
    when "check-in"
      check_in
    when "startup"
      record_action("logout") if logged_in?
    when "login"
      log_in
    when "logout"
      log_out if logged_in?
    end
  end
  
  private
  
  def check_in
    touch(:last_checkin)
  end
  
  def logged_in?
    (current_status == "unavailable")
  end
  
  def log_in
    record_action("logout") if logged_in?
    login_time = Time.now
    logs.create!({ :operation => "login", :login_time => login_time })
    update_attributes!({ :last_login => login_time, :current_status => "unavailable" })
  end
  
  def log_out
    logs.order('login_time desc').first.update_attributes!({ :operation => "logout", :logout_time => Time.now })
    update_attributes!({ :current_status => "available", :current_user => nil, :current_vm => nil })
  end
  
  def maintain_site
    site = Site.match_name_with_site(self.name)
    self.site_id = if site.instance_of? Site then site.id else nil end
  end
end
