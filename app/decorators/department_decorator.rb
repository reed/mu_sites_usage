class DepartmentDecorator < ApplicationDecorator
  decorates :department
  
  def status_data
    counts = model.status_counts
    "data-available=""#{counts[:available]}"" data-unavailable=""#{counts[:unavailable]}"" data-offline=""#{counts[:offline]}"""
  end
  
  def windows_client_count
    sites.count > 0 ? model.client_count("windows") : 0
  end
  
  def mac_client_count
    sites.count > 0 ? model.client_count("macs") : 0
  end

  def site_type_links(current)
    links = ""
    model.sites.pluck(:site_type).uniq.each do |t|
      is_current = t == current
      links += site_type_link(t, is_current).html_safe
    end
    links.html_safe
  end
  
  def site_type_link(type, current = false)
    klass = current ? "current" : ""
    link = h.link_to type.titleize + " Sites", h.department_path(self) + "?type=" + type.to_param
    h.content_tag(:li, link, :class => klass, "data-type" => type)
  end
end