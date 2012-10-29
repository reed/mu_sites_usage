class Site < ActiveRecord::Base
  extend FriendlyId
  friendly_id :short_name
  
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
  has_many :snapshots, :dependent => :destroy
  
  def self.match_name_with_site(name)
    name.upcase!
    concat_operator = ENV['RAILS_ENV'] == "production" ? "+" : "||"
    where(["? LIKE (name_filter #{concat_operator} '%')", name]).first
  end
  
  def self.refilter_clients
    Client.recheck_sites
  end
  
  def self.take_snapshots
    enabled.each{ |s| s.take_snapshot }
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
  
  def status_counts
    counts = { available: 0, unavailable: 0, offline: 0 }
    retrieved_counts = clients.enabled.group(:current_status).count
    retrieved_counts.each_pair {|k,v| counts[k.to_sym] = v }
    counts
  end
  
  def status_counts_by_type
    init_counts = {
      :total => 0,
      :available => 0,
      :unavailable => 0,
      :offline => 0,
    }
    init_type_counts = {
      :pc => init_counts.dup,
      :tc => init_counts.dup,
      :mac => init_counts.dup
    }
    counts = Client.enabled.where(:site_id => id).group(:client_type, :current_status).count
    counts.each_pair do |k,v|
      t = k[0] == "zc" ? :tc : k[0].to_sym
      init_type_counts[t][k[1].to_sym] += v
    end
    init_type_counts.each_pair{|k,v| init_type_counts[k][:total] = v.values.inject(0){|sum, i| sum + i}}
  end
  
  def take_snapshot
    snapshots.create!(status_counts)   
  end
end
