require 'net/ldap'

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
  
  LDAP = SitesUsage::Application.config.ldap
  
  belongs_to :department
  
  def authenticated_user?
    ROLES.include?(role)
  end
  
  def site_manager?
    ["site_manager", "department_manager", "administrator"].include?(role)
  end
  
  def department_manager?
    ["department_manager", "administrator"].include?(role)
  end
  
  def administrator?
    role == "administrator"
  end
  
  def self.authenticate(username, password)
    user = User.find_by_username(username)
    return nil if user.nil?
    return user if user.authenticates?(password)
  end
  
  def authenticates?(password)
    ldap_con = initialize_ldap_con(LDAP['username'], LDAP['password'])
    login_filter = Net::LDAP::Filter.eq( "sAMAccountName", username )
    object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )
    dn = String.new
    ldap_con.search(:base => "DC=edu", :filter => login_filter & object_filter, :attributes => ["dn"]) do |entry|
      dn = entry.dn
    end
    return false if dn.empty?
    ldap_con = initialize_ldap_con(dn, password)
    ldap_con.bind
  end
  
  private
  
  def initialize_ldap_con(ldap_user, ldap_password)
    options = { :host => LDAP['host'],
                :port => LDAP['port'],
                :encryption => nil
              }
    options.merge!(:auth => { :method => :simple, :username => ldap_user, :password => ldap_password }) unless ldap_user.blank? && ldap_password.blank?
    Net::LDAP.new options
  end
end
