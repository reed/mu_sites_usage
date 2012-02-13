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
    sum = 0
    sites.each do |site|
      sum += site.client_count(type)
    end
    sum
  end
  
  def status_count
    statuses = {
      :available => 0,
      :unavailable => 0,
      :offline => 0
    }
    statuses.each_key do |s| 
      total = 0
      sites.each { |site| total += site.status_count(s) }
      statuses[s.to_sym] = total 
    end  
    statuses
  end
end
