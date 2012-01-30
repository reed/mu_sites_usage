class User < ActiveRecord::Base
  attr_accessible :username, :name, :email, :role
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  ROLES = %w[authenticated_user site_manager department_manager administrator]
  validates :username,  :presence => true,
                        :uniqueness => { :case_sensitive => false },
                        :length => { :maximum => 40 }
  validates :name,      :presence => true
  validates :email,     :presence => true,
                        :uniqueness => { :case_sensitive => false },
                        :format => { :with => email_regex }
  validates :role,      :presence => true,
                        :inclusion => { :in => ROLES }
  validates :department_id, :presence => true
  
  belongs_to :department
  
  def self.authenticate(username, password)
    user = User.find_by_username(username)
    return nil if user.nil?
    return user  # if user.authenticates?(password)
  end
  
  private
  
  # def authenticates?(password)
  #   
  # end
end
