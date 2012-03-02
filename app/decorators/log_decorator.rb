class LogDecorator < ApplicationDecorator
  decorates :log

  def device_info_toggler
    name = h.content_tag :span, model.client.name, :class => "name"
    mac = h.content_tag :span, model.client.mac_address, :class => "mac_address"
    ip = h.content_tag :span, model.client.ip_address, :class => "ip_address"
    h.content_tag :span, name + mac + ip, :class => "device_info_toggler"
  end

  def duration
    if model.login_time.present? && model.logout_time.present?
      h.distance_of_time_in_words(model.login_time, model.logout_time).capitalize
    elsif model.login_time.present?
      h.distance_of_time_in_words_to_now(model.login_time).capitalize
    else
      ""
    end
  end
end