class ClientDecorator < ApplicationDecorator
  decorates :client
  delegate_all
  
  def client_cell(details = false)
    status = model.current_status
    type = model.client_type == "mac" ? "mac" : "windows"
    light = light(status)
    left_type_icon = h.image_tag "#{type}_#{status}.png", :title => type.capitalize, :height => "16", :class => "type-icon"
    right_type_icon = h.image_tag "#{type}_#{status}.png", :title => type.capitalize, :height => "16", :class => "type-icon-right"
    if details
      name = h.content_tag :span, model.name, :class => "cycle"
      mac = h.content_tag :span, model.mac_address, :class => "cycle"
      ip = h.content_tag :span, model.ip_address, :class => "cycle"
      msg = h.content_tag :span, status_message, :class => "status-message"
      data = name + mac + ip + user_info + vm_name + msg
    else
      name = h.content_tag :span, model.name
      data = name  
    end
    h.content_tag :div, light + left_type_icon + data + right_type_icon + light, {:class => "device #{status}", "data-status" => status, "data-type" => type }  
  end
  
  def user_info 
    if model.logged_in? && model.current_user.present?
      uid = h.content_tag :span, model.current_user, :class => "user_toggler uid"
      ldap = Ldap.new
      display_name = ldap.get_display_name(model.current_user)
      display_name = model.current_user if display_name.empty?
      u_name = h.content_tag :span, display_name, :class => "user_toggler display-name"
      data = uid + u_name
    else
      data = "Unknown User"
    end
    h.content_tag :span, data, :class => "user"
  end
  
  def vm_name
    if model.logged_in? && model.current_vm.present?
      h.content_tag :span, model.current_vm, :class => "vm"
    else
      h.content_tag :span, "Unknown VM", :class => "vm"
    end
  end
  
  def status_message
    case model.current_status
    when "available"
      if model.last_login.present?
        if model.last_login < 1.day.ago
          "Last login: #{model.last_login.strftime("%a, %-m/%-d at %-l:%M %p")} (#{h.time_ago_in_words(model.last_login)} ago)"
        else
          "Last login: #{model.last_login.strftime("%-l:%M %p")} (#{h.time_ago_in_words(model.last_login)} ago)"
        end
      else
        "No previous logins"
      end
    when "unavailable"
      "Logged in for #{h.time_ago_in_words(model.last_login)}"
    when "offline"
      last_checkin = model.last_checkin
      last_checkin ||= model.updated_at
      if last_checkin < 1.day.ago
        "Offline since #{last_checkin.strftime("%a, %-m/%-d at %-l:%M %p")} (#{h.time_ago_in_words(last_checkin)} ago)"
      else
        "Offline since #{last_checkin.strftime("%-l:%M %p")} (#{h.time_ago_in_words(last_checkin)} ago)"
      end
    end
  end
end