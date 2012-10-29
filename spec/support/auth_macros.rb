module AuthMacros
  def log_in(attributes = {})
    @_current_user = create(:user, attributes)
    puts @_current_user.to_yaml
    visit login_path
    fill_in "Username", with: @_current_user.username
    fill_in "Password", with: "password"
    click_button "Sign in"
    page.should have_content "Logged in"
  end

  def current_user
    @_current_user
  end
end