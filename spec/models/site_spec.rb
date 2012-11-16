require 'spec_helper'

describe Site do
  describe "Site Creation" do
    before(:each) do
      @dept = FactoryGirl.create(:department)
      @attr = {
        :display_name => "Site",
        :short_name => "site",
        :name_filter => "SITE-TC-\\S+"
      }
    end
    
    it "should create a site with valid attributes" do
      @dept.sites.create!(@attr)
    end
    
    it "should require a display name" do
      @dept.sites.build(@attr.merge(:display_name => "")).should_not be_valid
    end
    
    it "should require a short name" do
      @dept.sites.build(@attr.merge(:short_name => "")).should_not be_valid
    end
    
    it "should reject duplicate short names" do
      @dept.sites.create!(@attr)
      @dept.sites.build(@attr).should_not be_valid
    end
    
    it "should reject duplicate short names regardless of case" do
      @dept.sites.create!(@attr)
      upcased_short_name = @attr[:short_name].upcase
      @dept.sites.build(@attr.merge(:short_name => upcased_short_name)).should_not be_valid
    end
    
    it "should reject invalid short names" do
      short_names = ["site-test", "site test", "SITE"]
      short_names.each do |short_name|
        @dept.sites.build(@attr.merge(:short_name => short_name)).should_not be_valid
      end
    end
    
    it "should require a name filter" do
      @dept.sites.build(@attr.merge(:name_filter => "")).should_not be_valid
    end
    
    it "should reject name filters with invalid regular expression" do
      @dept.sites.build(@attr.merge(:name_filter => "(SITE-\\S+")).should_not be_valid
    end
    
    it "should require a department" do
      Site.new(@attr).should_not be_valid
    end
  end
end
