class Client < ActiveRecord::Base
  
  mac_regex = /\A[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}:[a-z0-9]{2}\z/
  ip_regex = /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/
  
  WINDOWS_TYPES = %w[pc tc zc]
  MAC_TYPES = %w[mac]
  THINCLIENT_TYPES = %w[tc zc]
  PC_TYPES = %w[pc]
  
  TYPES = WINDOWS_TYPES + MAC_TYPES
   
  validates :name, :presence => true,
                    :length => { :maximum => 25 },
                    :uniqueness => { :case_sensitive => false }
  validates :mac_address, :presence => true,
                          :length => { :is => 17 },
                          :format => { :with => mac_regex }
  validates :ip_address, :format => { :with => ip_regex }
  validates :client_type, :presence => true,
                          :inclusion => { :in => TYPES }
  validates :current_status, :inclusion => { :in => ["available", "unavailable", "offline"] }
  
  belongs_to :site  
  has_many :logs
  
  scope :enabled, where(:enabled => true)
  scope :windows, where(:client_type => WINDOWS_TYPES)
  scope :macs, where(:client_type => MAC_TYPES)
  scope :pcs, where(:client_type => PC_TYPES)
  scope :thinclients, where(:client_type => THINCLIENT_TYPES) 
  scope :stale, lambda { where(:client_type => ["mac", "pc", "tc"]).where('name NOT LIKE ?', '%LT-%').where('last_checkin < ?', 10.minutes.ago) }
  scope :stalelaptops, lambda { where('name LIKE ?', '%LT-%').where('last_checkin < ?', 10.minutes.ago) }
  scope :orphaned, where(:site_id => nil)
  
  before_update :maintain_site
  
  def as_json(opts={})
    super opts.merge!({:except => [:__rn, :__rt]})
  end
  
  def department
    site.department if site
  end
  
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
      if !client.enabled? && Client.where({:mac_address => properties[:mac_address], :enabled => true}).exists?
        update_all({:enabled => false}, :mac_address => properties[:mac_address])
        properties.merge!({:enabled => true}) 
      end
      client.update_attributes(properties)
      client
    end
  end
  
  def self.check_statuses
    scoped_by_enabled(true).stale.each do |c|
      unless c.current_status == "offline"
        c.send('offline_log_out') if c.current_status == "unavailable"
        c.update_column(:current_status, 'offline')
      end
    end
    scoped_by_enabled(true).stalelaptops.each do |l|
      if l.current_status == "unavailable"
        l.send('offline_log_out')
        l.update_column(:current_status, 'available')
      end
    end
  end
  
  def self.recheck_sites
    all.each do |c|
      c.send :maintain_site
      c.save
    end
  end
  
  def self.search(filters)
    if filters
      s = includes(:site)
      if filters[:text]
        s = s.where("name LIKE ? 
                      OR mac_address LIKE ? 
                      OR ip_address LIKE ?", "%#{filters[:text]}%",
                                              "%#{filters[:text]}%",
                                              "%#{filters[:text]}%")
      end
      if filters[:type]
        s = s.where(:client_type => filters[:type])
      end
      if filters[:site]
        s = s.where("site_id" => filters[:site])
      end
      s
    else
      includes(:site)
    end
  end
  
  def self.search_tokens(query)
    select("id, name").where("name LIKE ? 
              OR mac_address LIKE ? 
              OR ip_address LIKE ?", "#{query}%",
                                      "#{query}%",
                                      "#{query}%")
  end
  
  def record_action(operation, user_id = nil, vm = nil)
    case operation.downcase
    when "check-in"
      check_in
    when "startup"
      logged_in? ? record_action("logout") : check_in
    when "login"
      log_in(user_id, vm)
    when "logout"
      log_out if logged_in?
    end
  end
  
  def logged_in?
    (current_status == "unavailable")
  end
  
  private
  
  def check_in
    touch(:last_checkin)
    update_column(:current_status, "available") if current_status == "offline"
  end
 
  def log_in(user_id = nil, vm = nil)
    record_action("logout") if logged_in?
    login_time = Time.now
    logs.create!({ :operation => "login", :login_time => login_time, :user_id => user_id, :vm => vm })
    update_attributes!({ :last_login => login_time, :current_status => "unavailable", :current_user => user_id, :current_vm => vm, :last_checkin => login_time })
  end
  
  def log_out
    logs.order('login_time desc').first.update_attributes!({ :operation => "logout", :logout_time => Time.now })
    update_attributes!({ :current_status => "available", :current_user => nil, :current_vm => nil, :last_checkin => Time.now })
  end
  
  def offline_log_out
    logs.order('login_time desc').first.update_attributes!({ :operation => "logout", :logout_time => Time.now })
    update_column(:current_user, nil)
    update_column(:current_vm, nil)
  end
  
  def maintain_site
    site = Site.match_name_with_site(self.name)
    self.site_id = if site.instance_of? Site then site.id else nil end
  end
end
