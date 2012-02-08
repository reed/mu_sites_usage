class Ldap
  require 'net/ldap'
  LDAP_SETTINGS = SitesUsage::Application.config.ldap
  
  def initialize(username = LDAP_SETTINGS['username'], password = LDAP_SETTINGS['password'])
    options = { :host => LDAP_SETTINGS['host'],
                :port => LDAP_SETTINGS['port'],
                :encryption => nil
    }
    options.merge!(:auth => { :method => :simple, :username => username, :password => password })
    @ldap_con = Net::LDAP.new options
  end
  
  def bind
    @ldap_con.bind
  end
  
  def authenticates?(username, password)
    login_filter = Net::LDAP::Filter.eq( "sAMAccountName", username )
    object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )
    dn = get_dn(username)
    return false if dn.empty?
    auth_connection = Ldap.new(dn, password)
    auth_connection.bind
  end
  
  def is_member?(username, group)
    group_dn = get_dn(group)
    group_members = get_members(group_dn)
    user_dn = get_dn(username)
    group_members.include? user_dn
  end
  
  def get_attributes_for_new_user(username)
    name_filter = Net::LDAP::Filter.eq( "sAMAccountName", username )
    object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )
    attributes = Hash.new
    @ldap_con.search(:base => "DC=edu", :filter => name_filter & object_filter, :attributes => ["sn", "givenname", "mail", "userprincipalname"]) do |entry|
      if entry.respond_to? :mail
        email = entry.mail
      else
        email = entry.userprincipalname
      end
        
      attributes = {:name => "#{entry.givenname[0]} #{entry.sn[0]}", :email => email[0] }
    end
    attributes.merge({:role => "authenticated_user" })
  end
  
  def get_display_name(username)
    name_filter = Net::LDAP::Filter.eq( "sAMAccountName", username )
    object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )
    display_name = String.new
    @ldap_con.search(:base => "DC=edu", :filter => name_filter & object_filter, :attributes => ["displayname"]) do |entry|
      display_name = entry.displayname[0].to_s
    end
    if display_name.index('(')
      display_name[0, display_name.index('(')].strip
    else
      display_name
    end
  end
  
  def get_members(dn)
    group_filter = Net::LDAP::Filter.eq( "distinguishedName", dn)
    object_filter = Net::LDAP::Filter.eq( "objectclass", "group")
    members = Array.new
    @ldap_con.search(:base => "DC=edu", :filter => group_filter & object_filter, :attributes => ["objectclass", "member"]) do |entry|
      members = entry.member
    end
    member_users = Array.new
    members.each do |member|
      if is_account_type?(member, "group")
        member_users += get_members(member)
      elsif is_account_type?(member, "user")
        member_users << member
      end
    end
    member_users
  end
  
  def get_dn(sAMAccountName)
    name_filter = Net::LDAP::Filter.eq( "sAMAccountName", sAMAccountName )
    object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )
    dn = String.new
    @ldap_con.search(:base => "DC=edu", :filter => name_filter & object_filter, :attributes => ["dn"]) do |entry|
      dn = entry.dn
    end
    dn
  end
  
  def is_account_type?(dn, type)
    dn_filter = Net::LDAP::Filter.eq( "distinguishedName", dn)
    object_filter = Net::LDAP::Filter.eq( "objectclass", type)
    @ldap_con.search(:base => "DC=edu", :filter => dn_filter & object_filter).any?
  end
end