class LogDecorator < ApplicationDecorator
  decorates :log

  def device_info_toggler
    name = h.content_tag :span, model.client.name, :class => "name"
    mac = h.content_tag :span, model.client.mac_address, :class => "mac_address"
    ip = h.content_tag :span, model.client.ip_address, :class => "ip_address"
    h.content_tag :span, name + mac + ip, :class => "device_info_toggler"
  end

end