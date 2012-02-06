require 'spec_helper'

describe User do
  describe "validations" do
    before(:each) do 
      @dept = Factory(:department)
      @attr = {
        :username => "testuser",
        :name => "Test User",
        :email => "testuser@missouri.edu",
        :role => "authenticated_user"
      }
    end
    
    it "should create a user given valid attributes" do
      @dept.users.create!(@attr)
    end
    
    it "should require a department" do
      User.new(@attr).should_not be_valid
    end
    
    it "should require a username" do
      @dept.users.build(@attr.merge({:username => ""})).should_not be_valid
    end
    
    it "should require a name" do
      @dept.users.build(@attr.merge({:name => ""})).should_not be_valid
    end
    
    it "should reject usernames that are too long" do
      long_name = "a" * 41
      @dept.users.build(@attr.merge({:username => long_name})).should_not be_valid
    end
    
    it "should require an email address" do
      @dept.users.build(@attr.merge({:email => ""})).should_not be_valid
    end
    
    it "should reject duplicate usernames" do
      @dept.users.create!(@attr)
      @dept.users.build(@attr.merge({:name => "Test User 2", :email => "testuser2@missouri.edu"})).should_not be_valid
    end
    
    it "should reject duplicate email addresses" do
      @dept.users.create!(@attr)
      @dept.users.build(@attr.merge({:username => "testuser2", :name => "Test User 2"})).should_not be_valid
    end
    
    it "should reject invalid email addresses" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |address|
        @dept.users.build(@attr.merge(:email => address)).should_not be_valid
      end
    end
    
    it "should accept valid email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        @dept.users.build(@attr.merge(:email => address)).should be_valid
      end
    end
    
    it "should have a login count of zero" do
      new_user = @dept.users.create!(@attr)
      new_user.logins.should == 0
    end
    
    it "should require a role" do
      @dept.users.build(@attr.merge({:role => ""})).should_not be_valid
    end
    
    it "should accept valid roles" do
      roles = %w[authenticated_user site_manager department_manager administrator]
      roles.each do |r|
        @dept.users.build(@attr.merge({:role => r})).should be_valid
      end
    end
    
    it "should reject invalid roles" do
      @dept.users.build(@attr.merge({:role => "other"})).should_not be_valid
    end
  end

  describe "roles" do
    before(:each) do
      @department = Factory(:department)
      @attr = {
        :username => "testuser",
        :name => "Test User",
        :email => "testuser@missouri.edu",
        :role => "authenticated_user"
      }
    end
    
    describe "authenticated user" do
      before(:each) do
        @user = @department.users.create!(@attr)
      end
      
      it "should be an authenticated user" do
        @user.should be_authenticated_user
      end
      
      it "should not be a site manager" do
        @user.should_not be_site_manager
      end
      
      it "should not be a department manager" do
        @user.should_not be_department_manager
      end
      
      it "should not be an administrator" do
        @user.should_not be_administrator
      end
    end
    
    describe "site manager" do
      before(:each) do
        @user = @department.users.create!(@attr.merge({:role => "site_manager"}))
      end
      
      it "should be an authenticated user" do
        @user.should be_authenticated_user
      end
      
      it "should be a site manager" do
        @user.should be_site_manager
      end
      
      it "should not be a department manager" do
        @user.should_not be_department_manager
      end
      
      it "should not be an administrator" do
        @user.should_not be_administrator
      end
    end
    
    describe "department manager" do
      before(:each) do
        @user = @department.users.create!(@attr.merge({:role => "department_manager"}))
      end
      
      it "should be an authenticated user" do
        @user.should be_authenticated_user
      end
      
      it "should be a site manager" do
        @user.should be_site_manager
      end
      
      it "should be a department manager" do
        @user.should be_department_manager
      end
      
      it "should not be an administrator" do
        @user.should_not be_administrator
      end
    end
    
    describe "administrator" do
      before(:each) do
        @user = @department.users.create!(@attr.merge({:role => "administrator"}))
      end
      
      it "should be an authenticated user" do
        @user.should be_authenticated_user
      end
      
      it "should be a site manager" do
        @user.should be_site_manager
      end
      
      it "should be a department manager" do
        @user.should be_department_manager
      end
      
      it "should be an administrator" do
        @user.should be_administrator
      end
    end
  end
end
