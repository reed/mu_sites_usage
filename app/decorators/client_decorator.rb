class ClientDecorator < ApplicationDecorator
  decorates :client

  def client_cell(details = false)
    status = model.current_status
    type = model.client_type == "mac" ? "mac" : "windows"
    light = light(status)
    left_type_icon = h.image_tag "#{type}.png", :title => type.capitalize, :height => "16", :class => "type-icon"
    right_type_icon = h.image_tag "#{type}.png", :title => type.capitalize, :height => "16", :class => "type-icon-right"
    if details
      name = h.content_tag :span, model.name, :class => "cycle"
      mac = h.content_tag :span, model.mac_address, :class => "cycle"
      ip = h.content_tag :span, model.ip_address, :class => "cycle"
      h.content_tag :div, light + left_type_icon + name + mac + ip + right_type_icon + light, :class => "device #{status}"
    else
      name = h.content_tag :span, model.name
      h.content_tag :div, light + left_type_icon + name + right_type_icon + light, :class => "device #{status}"  
    end
  end
end