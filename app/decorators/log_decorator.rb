class LogDecorator < ApplicationDecorator
  decorates :log

  def device_info_toggler
    name = h.content_tag :span, model.client.name, :class => "name"
    mac = h.content_tag :span, model.client.mac_address, :class => "mac_address"
    ip = h.content_tag :span, model.client.ip_address, :class => "ip_address"
    h.content_tag :span, name + mac + ip, :class => "device_info_toggler"
  end

  def user
    if model.user_id.present?
      uid = h.content_tag :span, model.user_id, :class => "uid"
      ldap = Ldap.new
      display_name = ldap.get_display_name(model.user_id)
      if display_name.empty? 
        uid
      else
        u_name = h.content_tag :span, display_name, :class => "display-name"
        h.content_tag :span, uid + u_name, :class => "user_toggler"
      end
    else
      ""
    end
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