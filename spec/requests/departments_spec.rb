require 'spec_helper'

describe "Department request" do
  it "lists departments as guest" do
    create(:department, display_name: "A Department")
    create(:department, display_name: "Another Department")
    visit departments_path
    page.should have_content("A Department")
    page.should have_content("Another Department")
  end
  
  it "creates department as administrator" do
    log_in :administrator
    visit departments_path
    click_on "New Department"
    fill_in "Display name", with: "A Department"
    fill_in "Short name", with: "adepartment"
    click_on "Create"
    page.should have_content("Department created.")
    page.should have_content("A Department")
  end
end