require 'spec_helper'

describe Log do
  describe "validations" do
    before(:each) do
      @client = FactoryGirl.create(:client)
      @attr = {
        :operation => "login",
        :login_time => 5.minutes.ago
      }
    end
    
    it "should create a log given valid attributes" do
      @client.logs.create!(@attr)
    end
    
    it "should require a client id" do
      Log.new(@attr).should_not be_valid
    end
    
    it "should require an operation" do
      @client.logs.build(@attr.merge(:operation => "")).should_not be_valid
    end
    
    it "should accept valid operations" do
      ["login", "logout"].each do |op|
        @client.logs.build(@attr.merge(:operation => op)).should be_valid
      end
    end
    
    it "should reject invalid operations" do
      ["Login", "startup", "anything else"].each do |op|
        @client.logs.build(@attr.merge(:operation => op)).should_not be_valid
      end
    end
  end
end
