json.sites @sites do |json, site|
  json.name site.display_name 
  json.devices site.clients.order(:name).decorate do |json, client|
    json.name client.name
    json.status client.current_status
    json.status_message client.status_message
  end
end