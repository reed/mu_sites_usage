require 'spec_helper'

describe ClientsController do
  render_views
  
  describe "POST 'upload'" do
    
    before(:each) do
      @post_data = {
        :client_type => "tc",
        :operation => "startup",
        :name => "SITE-TC-00",
        :mac_address => "78:12:ab:cd:98:ef",
        :ip_address => "111.222.111.333"
      }
    end
    
    it "should be successful" do
      post :upload, @post_data
      response.should be_success
    end
    
    describe "parameter validation" do
      it "should fail if client_type is invalid or missing" do
        ["", "wrong", "tc1"].each do |client_type|
          post :upload, @post_data.merge(:client_type => client_type)
          response.should_not be_success
        end
        post :upload, @post_data.reject {|k| k == :client_type}
        response.should_not be_success
      end
    
      it "should fail if name, mac_address, or ip_address are blank or missing" do
        [:name, :mac_address, :ip_address].each do |f|
          post :upload, @post_data.merge(f => "")
          response.should_not be_success
          post :upload, @post_data.reject {|k| k == f}
          response.should_not be_success
        end
      end
    
      it "shouldn't require a mac_address, ip_address, or operation if the client_type is a VM" do
        [:mac_address, :ip_address, :operation].each do |f|
          post :upload, @post_data.merge(:client_type => "vm", :vm => "vm", :user_id => "user").reject {|k| k == f}
          response.should be_success
        end
      end
    
      it "should accept valid operations" do
        ["check-in", "startup", "login", "logout"].each do |op|
          post :upload, @post_data.merge(:operation => op)
          response.should be_success
        end
      end
      
      it "should reject invalid operations" do
        post :upload, @post_data.merge(:operation => "wrong")
        response.should_not be_success
      end
      
      it "should require a username if the client_type isn't a TC and the operation is login" do
        ["pc", "mac", "vm"].each do |client_type|
          post :upload, @post_data.merge(:client_type => client_type, :vm => "vm", :operation => "login")
          response.should_not be_success
        end
      end
      
      it "should require a vm if the client_type is a VM" do
        post :upload, @post_data.merge(:client_type => "vm", :user_id => "user")
        response.should_not be_success
      end
      
      it "shouldn't require a vm if the client_type isn't a VM" do
        ["pc", "mac", "tc"].each do |client_type|
          post :upload, @post_data.merge(:client_type => client_type, :user_id => "user")
          response.should be_success
        end
      end
    end
    
    
    describe "recording" do
      before(:each) do
        @site = FactoryGirl.create(:site)
        @tc_post = {
          :client_type => "tc",
          :operation => "startup",
          :name => "#{@site.name_filter}01",
          :mac_address => "78:12:ab:cd:98:ef",
          :ip_address => "111.222.111.333"
        }
        @vm_post = {
          :client_type => "vm",
          :name => @tc_post[:name],
          :user_id => "testuser",
          :vm => "TEST-VM-01"
        }
      end
      
      it "should create the client if it doesn't exist" do
        lambda do
          post :upload, @tc_post
        end.should change(Client, :count).by(1)
      end
      
      it "should create a log entry" do
        lambda do
          post :upload, @tc_post.merge(:operation => "login")
        end.should change(Log, :count).by(1)
      end
      
      it "should change an existing log entry when logging out" do
        post :upload, @tc_post.merge(:operation => "login")
        lambda do
          post :upload, @tc_post.merge(:operation => "logout")
        end.should_not change(Log, :count)
      end
      
      it "should change the client's current status" do
        post :upload, @tc_post
        Client.find_by_name(@tc_post[:name]).current_status.should == "available"
        post :upload, @tc_post.merge(:operation => "login")
        Client.find_by_name(@tc_post[:name]).current_status.should == "unavailable"
        post :upload, @tc_post.merge(:operation => "logout")
        Client.find_by_name(@tc_post[:name]).current_status.should == "available"
      end
      
      it "should update the client with current user and vm" do
        post :upload, @tc_post.merge(:operation => "login")
        post :upload, @vm_post
        c = Client.find_by_name(@tc_post[:name])
        [c.current_user, c.current_vm].should == [@vm_post[:user_id], @vm_post[:vm]]
      end
      
      it "should update the log entry with current user and vm" do
        post :upload, @tc_post.merge(:operation => "login")
        post :upload, @vm_post
        l = Client.find_by_name(@tc_post[:name]).logs.last
        [l.user_id, l.vm].should == [@vm_post[:user_id], @vm_post[:vm]]
      end
    end     
  end
end
