class Site < ActiveRecord::Base
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
end
