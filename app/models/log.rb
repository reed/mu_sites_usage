class Log < ActiveRecord::Base
  attr_accessible :client_id, :operation, :login_time, :logout_time, :user_id, :vm
  
  validates :client_id, :presence => :true
  validates :operation, :presence => :true,
                      :inclusion => { :in => ["login", "logout"] }
                      
  belongs_to :client
  
  default_scope order('updated_at DESC')
end
