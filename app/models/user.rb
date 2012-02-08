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
    ldap = Ldap.new
    user = User.find_by_username(username)
    if user.nil?
      new_user = User.new({ :username => username })
      if ldap.authenticates?(new_user.username, password) && ldap.is_member?(new_user.username, "Sites Usage Authenticated Users")
        attributes = ldap.get_attributes_for_new_user(new_user.username)
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
      return user if ldap.authenticates?(user.username, password)
    end
  end
end
