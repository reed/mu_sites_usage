class Site < ActiveRecord::Base
  extend FriendlyId
  friendly_id :short_name
  
  short_name_regex = /\A[a-z0-9]*\z/
  
  TYPES = %w[general_access classroom residence_hall laptop_checkout internal]
  
  validate :name_filter_is_regex
  
  validates :display_name, :presence => true
  validates :short_name, :presence => true, 
                         :uniqueness => { :case_sensitive => false },
                         :format => { :with => short_name_regex }
  validates :name_filter, :presence => true
  validates :department_id, :presence => true
  validates :site_type, :presence => true,
                        :inclusion => { :in => TYPES }
  
  scope :enabled, -> { where(:enabled => true) }
  scope :external, -> { where(:site_type => TYPES - ['internal']) }
  default_scope -> { order('display_name ASC') }
  
  belongs_to :department
  has_many :clients, :dependent => :nullify
  has_many :snapshots, :dependent => :destroy
  
  def self.refilter_clients
    Client.recheck_sites
  end
  
  def self.take_snapshots
    enabled.each{ |s| s.take_snapshot }
  end
  
  def status_counts
    @status_counts ||= calculate_status_counts
  end
  
  def self.status_counts_by_type(sites)
    init_counts = {
      total: 0,
      available: 0,
      unavailable: 0,
      offline: 0,
    }
    init_type_counts = {
      pc: init_counts.dup,
      tc: init_counts.dup,
      mac: init_counts.dup
    }
    
    site_status_counts = Hash.new
    
    sites = sites.reorder('')
    counts = Client.enabled.where(:site_id => sites).group(:site_id, :client_type, :current_status).count
    
    sites.each do |site|
      site_status_counts[site.id] = Marshal.load(Marshal.dump(init_type_counts))
      site_counts = counts.select{|k,v| k[0] == site.id}
      site_counts.each_pair do |k,v|
        t = k[1] == 'zc' ? :tc : k[1].to_sym
        site_status_counts[site.id][t][k[2].to_sym] += v
      end
      site_status_counts[site.id].each_pair{|k,v| site_status_counts[site.id][k][:total] = v.values.reduce(:+)}
    end
    site_status_counts
  end
  
  def take_snapshot
    snapshots.create!(status_counts)   
  end
  
  private
  
  def name_filter_is_regex
    Regexp.new("^#{name_filter}$", true)
  rescue
    errors.add(:name_filter, "is not a valid regular expression")
  end
  
  def calculate_status_counts
    counts = { available: 0, unavailable: 0, offline: 0 }
    retrieved_counts = clients.enabled.group(:current_status).count
    retrieved_counts.each_pair {|k,v| counts[k.to_sym] = v }
    counts
  end
end
