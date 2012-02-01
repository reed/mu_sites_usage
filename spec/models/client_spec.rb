require 'spec_helper'

describe Client do
  describe "Validations" do
    before(:each) do
      @attr = {
        :name => "SITE-TC-01",
        :mac_address => "aa:aa:aa:aa:aa:aa",
        :ip_address => "100.100.100.100",
        :client_type => "tc"
      }
    end
    
    it "should create a client given valid attributes" do
      Client.create!(@attr)
    end
    
    it "should require a name" do
      Client.new(@attr.merge(:name => "")).should_not be_valid
    end
    
    it "should reject long names" do
      Client.new(@attr.merge(:name => "A" * 26)).should_not be_valid
    end
    
    it "should reject duplicate names" do
      Client.create!(@attr)
      Client.new(@attr).should_not be_valid
    end
    
    it "should require a mac address" do 
      Client.new(@attr.merge(:mac_address => "")).should_not be_valid
    end
    
    it "should reject invalid MAC addresses" do
      invalid_mac_addresses = ["abc", "ab.cd.ef.gh.ij.kl", "ab cd ef gh ij kl", "a1:b1:c1:d1:e1", "a1:b1:c1:d1:e1:f1:g1"]
      invalid_mac_addresses.each do |invalid_mac_address|
        Client.new(@attr.merge(:mac_address => invalid_mac_address)).should_not be_valid
      end
    end
    
    it "should reject invalid IP addresses" do
      invalid_ip_addresses = ["111222333444", "100:200:300:400", "1000.2.100.100", "100.200.100"]
      invalid_ip_addresses.each do |invalid_ip_address|
        Client.new(@attr.merge(:ip_address => invalid_ip_address)).should_not be_valid
      end
    end
    
    it "should accept valid IP addresses" do
      valid_ip_addresses = ["1.1.1.1", "10.10.10.10", "100.100.100.100", "1.23.456.789", "0.0.0.0"]
      valid_ip_addresses.each do |valid_ip_address|
        Client.new(@attr.merge(:ip_address => valid_ip_address)).should be_valid
      end
    end
    
    it "should require a type" do
      Client.new(@attr.merge(:client_type => "")).should_not be_valid
    end
    
    it "should accept valid types" do
      valid_types = ["tc", "pc", "mac"]
      valid_types.each do |valid_type|
        Client.new(@attr.merge(:client_type => valid_type)).should be_valid
      end
    end
    
    it "should reject invalid types" do
      invalid_types = ["thinclient", "TC", "PC", "other"]
      invalid_types.each do |invalid_type|
        Client.new(@attr.merge(:client_type => invalid_type)).should_not be_valid
      end
    end
    
    it "should be enabled by default" do
      Client.create!(@attr).should be_enabled
    end
  end
  
  describe "client matching" do
      
    before(:each) do 
      @site = Factory(:site)
      @client = Factory(:client)
      @attr = {
        :name => "SITE-TC-00",
        :mac_address => "aa:aa:aa:aa:aa:aa",
        :client_type => "tc",
        :ip_address => "1.1.1.1"
      }
    end
      
    it "should find an existing client by name" do
      Client.find_or_create(@attr.merge(:name => @client.name)).id.should == @client.id
    end
      
    it "should update the attributes of an existing client" do
      returned_client = Client.find_or_create(@attr.merge(:name => @client.name))
      returned_client.mac_address.should == @attr[:mac_address]
      returned_client.client_type.should == @attr[:client_type]
      returned_client.ip_address.should == @attr[:ip_address]
    end
      
    it "should create a client if a match is not found" do
      new_client = Client.find_or_create(@attr.merge(:name => "#{@site.name_filter}10"))
      Client.exists?(new_client.id).should be_true
    end
    
    it "should disable any old clients with matching mac address when creating a new client" do
      @client.should be_enabled
      Client.find_or_create(@attr.merge(:mac_address => @client.mac_address))
      Client.find(@client.id).should_not be_enabled
    end
      
    it "should update the site if the site name filter has changed" do
      client = Client.find_or_create(@attr.merge(:name => "#{@site.name_filter}10"))
      client.site.should == @site
      @site.update_attributes({:name_filter => "AAS-TC-"})
      client = Client.find_or_create(@attr.merge(:name => client.name))
      client.site.should be_nil
    end
  end
  
  describe "client actions" do
    before(:each) do
      @client = Factory(:client)
    end
    
    it "should update the last_checkin field" do
      initial_value = @client.last_checkin
      @client.record_action("check-in")
      updated_value = @client.last_checkin
      updated_value.should_not == initial_value
      @client.record_action("check-in")
      @client.last_checkin.should_not == updated_value
    end
    
    it "should change the status of a client" do
      @client.record_action('login')
      @client.should be_logged_in
      @client.record_action('logout')
      @client.should_not be_logged_in
    end
    
    it "should not be logged in after a startup" do
      @client.record_action('login')
      @client.record_action('startup')
      @client.should_not be_logged_in
    end
    
    it "should create a log entry" do
      lambda do 
        @client.record_action('login')
      end.should change(Log, :count).by(1)
    end
    
    it "should not create a log entry" do
      @client.record_action('login')
      lambda do
        @client.record_action('logout')
      end.should_not change(Log, :count)
    end
    
    it "should insert identical login times to each table" do
      @client.record_action('login')
      last_login = @client.reload.last_login
      login_time = @client.logs.last.login_time
      last_login.should == login_time
    end
    
    it "should change current_user and current_vm to nil after logout" do
      @client.update_attributes!({:current_user => "testuser", :current_vm => "TEST-VM-01" })
      @client.record_action('login')
      @client.record_action('logout')
      @client.reload.current_user.should be_nil
      @client.current_vm.should be_nil
    end
    
    it "should change status to offline if more than 10 minutes have passed since last check-in" do
      @client.update_attributes!({ :last_checkin => 11.minutes.ago })
      Client.check_statuses
      @client.reload.current_status.should == "offline"
    end
    
    it "should not change status for disabled clients" do
      @client.update_attributes!({ :last_checkin => 11.minutes.ago, :enabled => false })
      Client.check_statuses
      @client.reload.current_status.should_not == "offline"
    end
  end
  
  describe "scopes" do
    before(:each) do
        Factory(:client, :client_type => 'tc')
        Factory(:client, :client_type => 'pc')
        Factory(:client, :client_type => 'mac')
    end
    
    it "should only count windows clients" do
      Client.windows.count.should == 2
    end
    
    it "should only count mac clients" do
      Client.macs.count.should == 1
    end
  end
end
