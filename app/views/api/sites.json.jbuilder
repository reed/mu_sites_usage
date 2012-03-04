json.sites @sites do |json, site|
  json.name site.display_name 
  json.devices ClientDecorator.decorate(site.clients.order(:name)) do |json, client|
    json.name client.name
    json.status client.current_status
    json.status_message client.status_message
  end
end