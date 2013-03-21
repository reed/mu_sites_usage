class DepartmentDecorator < ApplicationDecorator
  decorates :department
  decorates_association :sites
  delegate_all
  
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

  def site_type_links(types, current)
    links = ""
    types.each do |t|
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
  
  def chart
    counts = model.status_counts
    total = counts.values.reduce(:+)
    data = []
    default_colors = {
      available: radial_gradient([[0,'#5BBD5C'], [0.95, '#42A443'], [1, '#0F7110']]), 
      unavailable: radial_gradient([[0, '#DBC067'], [0.95, '#C2A74E'], [1, '#8F741B']]), 
      offline: radial_gradient([[0, '#D66781'], [0.95, '#BD4E68'], [1, '#8A1B35']])
    }
    colors = []
    counts.each do |status,count|
      if count > 0
        data << [status.to_s.titleize, ((count / total.to_f) * 100).round(0).to_f]
        colors << default_colors[status]
      end
    end
    
    if data.empty?
      data << ['No clients', 100.0]
      colors << '#797982'
    end
    
    LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({
        plotBackgroundColor: nil, 
        plotBorderWidth: nil, 
        plotShadow: false, 
        backgroundColor: nil
      })
      f.options[:title][:text] = ''
      f.options[:credits][:enabled] = false
      f.options[:colors] = colors
      f.options[:tooltip][:formatter] = %|function(){ 
        return $('##{model.short_name}_chart').parent('.department_summary')[0].formatTooltip(this); 
      }|.js_code
      f.series({
        type: 'pie', 
        name: 'Department Summary', 
        data: data,
        startAngle: 180
      })
      f.plot_options({
        pie: {
          borderWidth: 0, 
          size: '100%', 
          innerSize: '80%', 
          dataLabels: {
            enabled: false
          },
          shadow: {
              color: '#000000',
              width: 2,
              offsetX: 0.5,
              offsetY: 0.5
            }
        }
      })
    end
  end
end