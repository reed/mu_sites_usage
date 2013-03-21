class SiteDecorator < ApplicationDecorator
  decorates :site
  decorates_association :clients
  delegate_all
  
  def status_data(counts)
    formatted_counts = Hash.new
    counts.each do |type, type_count|
      formatted_counts[type] = [type_count[:total], type_count[:available], type_count[:unavailable], type_count[:offline]].join('-')
    end
    "data-macs=""#{formatted_counts[:mac]}"" data-pcs=""#{formatted_counts[:pc]}"" data-thinclients=""#{formatted_counts[:tc]}"""
  end
  
  def pie_chart(counts)
    types = {
      pc: 'PCs', 
      mac: 'Macs', 
      tc: 'Thin Clients'
    }
    type_colors = {
      pc: radial_gradient([[0, '#64BBE6'], [0.95, '#186F9A'], [1, '#00234E']]), 
      mac: radial_gradient([[0, '#5C96B2'], [0.95, '#104A66'], [1, '#00001A']]),
      tc: radial_gradient([[0, '#87C7E6'], [0.95, '#3B7B9A'], [1, '#002F4E']]),
    }
    default_status_colors = {
      available: radial_gradient([[0,'#5BBD5C'], [0.95, '#42A443'], [1, '#0F7110']]), 
      unavailable: radial_gradient([[0, '#DBC067'], [0.95, '#C2A74E'], [1, '#8F741B']]), 
      offline: radial_gradient([[0, '#D66781'], [0.95, '#BD4E68'], [1, '#8A1B35']])
    }
    total_clients = counts.values.inject(0){|sum, type| sum += type[:total]}
    
    type_series = {
      name: 'Client Types',
      size: '80%',
      innerSize: '8%',
      data: [],
      dataLabels: {
        color: '#001621',
        distance: -60,
        style: { fontSize: '16px', fontFamily: '"Trebuchet MS",Helvetica,sans-serif'},
        formatter: data_label_formatter(total_clients)
      },
      startAngle: 120
    }
    
    status_series = {
      name: 'Status',
      size: '100%',
      innerSize: '80%',
      data: [],
      dataLabels: { enabled: false },
      startAngle: 120
    }
    
    data,categories,colors = [],[],[]
    if total_clients > 0
      counts.each_pair do |type, type_counts|
        if type_counts[:total] > 0
          categories << types[type]
          
          this_data = {
            y: (type_counts[:total] / total_clients.to_f) * 100,
            color: type_colors[type],
            drilldown: {
              name: types[type],
              categories: [],
              data: [],
              colors: []
            }
          }
          
          type_counts.each_pair do |status, status_count|
            if status != :total && status_count > 0
              this_data[:drilldown][:categories] << "#{status.to_s.titleize} #{types[type]}"
              this_data[:drilldown][:data] << (status_count / total_clients.to_f) * 100
              this_data[:drilldown][:colors] << default_status_colors[status] 
            end
          end
        
          data << this_data
        end
      end
    else
      data << {
        y: 100.0,
        color: '#797982',
        drilldown: {
          name: 'No clients',
          categories: ['No clients'],
          data: [100.0],
          colors: [radial_gradient([[0,'#ACACB5'],[1,'#606069']])]
        }
      }
    end
    
    data.each_with_index do |type, i|
      type_series[:data] << {
        name: categories[i],
        y: type[:y],
        color: type[:color]
      }
      type[:drilldown][:categories].each_with_index do |status, j|
        status_series[:data] << {
          name: status,
          y: type[:drilldown][:data][j],
          color: type[:drilldown][:colors][j]
        }
      end
    end
    
    LazyHighCharts::HighChart.new('pie') do |f|
      f.chart({
        type: 'pie',
        plotBackgroundColor: nil, 
        plotBorderWidth: nil, 
        plotShadow: false, 
        backgroundColor: nil
      })
      f.options[:title][:text] = ''
      f.options[:credits][:enabled] = false
      f.options[:colors] = colors
      f.options[:tooltip][:formatter] = %|function(){ 
        return $('##{model.short_name}_chart').parent('.site_summary')[0].formatTooltip(this, #{total_clients}); 
      }|.js_code
      f.series(type_series)
      f.series(status_series)
      f.plot_options({
        pie: {
          borderWidth: 0, 
          borderColor: '#001621',
          size: '100%'
        }
      })
    end
  end
  
  def client_pane(details = false)
    if model.clients.enabled.empty?
      h.content_tag :div, "No computers", :class => "no_computers"
    else
      devices = Array.new
      model.clients.enabled.order(:name).decorate.each do |client| 
        devices << client.client_cell(details)
      end
      columnize(devices)
    end
  end
  
  private
  
  def columnize(devices, column_count = 5)
    columns = Array.new
    if devices.length < column_count
      devices.each do |device|
        column = h.content_tag :div, device.html_safe, :class => "device_column"
        columns << column
      end
    else
      min, rem = devices.length.divmod(column_count)
      column_count.times do |i|
        slice_size = i < rem ? min + 1 : min
        slice = devices.slice!(0, slice_size)
        column = h.content_tag :div, slice.join('').html_safe, :class => "device_column"
        columns << column
      end
    end
    columns.join('').html_safe
  end
  
  def data_label_formatter(count)
    value = count == 0 ? 'No computers' : "' + this.point.name.replace(' ', '</b><br/><b>') + '"
    %|function(){ return '<b>#{value}</b>'; }|.js_code
  end

end