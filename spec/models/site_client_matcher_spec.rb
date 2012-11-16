require 'spec_helper'

describe SiteClientMatcher do

  describe "Site Filtering" do
    
    before(:each) do
      @site = FactoryGirl.create(:site)
    end
    
    it "should match a name to the correct site" do
      SiteClientMatcher.site_matches_for_client_name("#{@site.name_filter}01").should include @site
    end
    
    it "should return the unkown site when a match is not found" do
      SiteClientMatcher.site_matches_for_client_name("SITE-TC-01").first.should be_nil
    end
  end
end