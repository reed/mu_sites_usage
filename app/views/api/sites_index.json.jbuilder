json.sites @sites do |json, site|
  json.name site.display_name
  json.short_name site.short_name
end