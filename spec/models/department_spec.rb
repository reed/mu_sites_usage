require 'spec_helper'

describe Department do
  describe "creation" do
    before(:each) do 
      @attr = {
        :display_name => "Computing Sites",
        :short_name => "sites",
      }
    end
    
    it "should create a department with valid attributes" do
      Department.create!(@attr)
    end
    
    it "should require a display name" do
      no_display_name_department = Department.new(@attr.merge(:display_name => ""))
      no_display_name_department.should_not be_valid
    end
    
    it "should require a short name" do
      no_short_name_department = Department.new(@attr.merge(:short_name => ""))
      no_short_name_department.should_not be_valid
    end
    
    it "should reject duplicate short names" do
      Department.create!(@attr)
      department_with_duplicate_short_name = Department.new(@attr)
      department_with_duplicate_short_name.should_not be_valid
    end
    
    it "should reject duplicate short names regardless of case" do
      Department.create!(@attr)
      upcased_short_name = @attr[:short_name].upcase
      department_with_duplicate_short_name = Department.new(@attr.merge(:short_name => upcased_short_name))
      department_with_duplicate_short_name.should_not be_valid
    end
    
    it "should reject invalid short names" do
      short_names = ["dept-test", "dept test", "DEPT"]
      short_names.each do |short_name|
        invalid_short_name_department = Department.new(@attr.merge(:short_name => short_name))
        invalid_short_name_department.should_not be_valid
      end
    end
  end
end
