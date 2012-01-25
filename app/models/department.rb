class Department < ActiveRecord::Base
  attr_accessible :display_name, :short_name
  
  short_name_regex = /\A[a-z0-9]*\z/
  
  validates :display_name, :presence => true
  validates :short_name, :presence => true, 
                         :uniqueness => { :case_sensitive => false },
                         :format => { :with => short_name_regex }
                         
  has_many :sites
end
