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
  
  def self.beneath_me(me)
    case me.role
    when "administrator" 
      where("role == ? OR role == ? OR role == ? OR id == ?", "authenticated_user", "site_manager", "department_manager", me.id)
    when "department_manager" 
      where("(role == ? OR role == ? OR id == ?) AND department_id == ?", "authenticated_user", "site_manager", me.id, me.department_id)
    when "site_manager" 
      where("(role == ? OR id == ?) AND department_id == ?", "authenticated_user", me.id, me.department_id)
    end
  end
  
  def assignable_roles
      case self.role
      when "administrator"
        ROLES
      when "department_manager"
        ROLES[0..1]
      when "site_manager"
        ROLES[0..0]
      else
        []
      end
  end    
  
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
    if user.nil?
      new_user = User.new({ :username => username })
      if new_user.authenticates?(password) && new_user.is_member?("Sites Usage Authenticated Users")
        attributes = new_user.get_attributes_for_new_user
        new_user[:name] = attributes[:name]
        new_user[:email] = attributes[:email]
        new_user[:role] = attributes[:role]
        new_user[:department_id] = Department.find_by_display_name("Computing Sites")[:id]
        if new_user.save
          return new_user
        else
          return nil
        end
      else
        return nil
      end
    else
      return user if user.authenticates?(password)
    end
  end
  
  def authenticates?(password)
    ldap_con = initialize_ldap_con(LDAP['username'], LDAP['password'])
    login_filter = Net::LDAP::Filter.eq( "sAMAccountName", username )
    object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )
    dn = get_dn(ldap_con, username)
    return false if dn.empty?
    ldap_con = initialize_ldap_con(dn, password)
    ldap_con.bind
  end
  
  def is_member?(group)
    ldap_con = initialize_ldap_con(LDAP['username'], LDAP['password'])
    group_dn = get_dn(ldap_con, group)
    group_members = get_members(ldap_con, group_dn)
    user_dn = get_dn(ldap_con, username)
    group_members.include? user_dn
  end
  
  def get_attributes_for_new_user
    ldap_con = initialize_ldap_con(LDAP['username'], LDAP['password'])
    name_filter = Net::LDAP::Filter.eq( "sAMAccountName", username )
    object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )
    attributes = Hash.new
    ldap_con.search(:base => "DC=edu", :filter => name_filter & object_filter, :attributes => ["sn", "givenname", "mail", "userprincipalname"]) do |entry|
      if entry.respond_to? :mail
        email = entry.mail
      else
        email = entry.userprincipalname
      end
        
      attributes = {:name => "#{entry.givenname[0]} #{entry.sn[0]}", :email => email[0] }
    end
    attributes.merge({:role => "authenticated_user" })
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
  
  def get_members(ldap_con, dn)
    group_filter = Net::LDAP::Filter.eq( "distinguishedName", dn)
    object_filter = Net::LDAP::Filter.eq( "objectclass", "group")
    members = Array.new
    ldap_con.search(:base => "DC=edu", :filter => group_filter & object_filter, :attributes => ["objectclass", "member"]) do |entry|
      members = entry.member
    end
    member_users = Array.new
    members.each do |member|
      if is_account_type?(ldap_con, member, "group")
        member_users += get_members(ldap_con, member)
      elsif is_account_type?(ldap_con, member, "user")
        member_users << member
      end
    end
    member_users
  end
  
  def get_dn(ldap_con, sAMAccountName)
    name_filter = Net::LDAP::Filter.eq( "sAMAccountName", sAMAccountName )
    object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )
    dn = String.new
    ldap_con.search(:base => "DC=edu", :filter => name_filter & object_filter, :attributes => ["dn"]) do |entry|
      dn = entry.dn
    end
    dn
  end
  
  def is_account_type?(ldap_con, dn, type)
    dn_filter = Net::LDAP::Filter.eq( "distinguishedName", dn)
    object_filter = Net::LDAP::Filter.eq( "objectclass", type)
    ldap_con.search(:base => "DC=edu", :filter => dn_filter & object_filter).any?
  end
  
end
