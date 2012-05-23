json.name @client.name
json.type @client.client_type
if @client.site
  json.site @client.site.display_name
end
json.status @client.current_status
if @client.current_status == "unavailable"
  json.user_id @client.current_user
  json.username @username
else
  json.last_user_id @user_id
  json.last_username @username
  json.last_logout @last_logout.strftime("%a, %-m/%-d at %-l:%M %p")
end
json.last_login @client.last_login.strftime("%a, %-m/%-d at %-l:%M %p")
