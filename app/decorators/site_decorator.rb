class SiteDecorator < ApplicationDecorator
  decorates :site

  def status_data
    counts = model.status_counts_by_type
    formatted_counts = Hash.new
    counts.each do |type, type_count|
      formatted_counts[type] = [type_count[:total], type_count[:available], type_count[:unavailable], type_count[:offline]].join('-')
    end
    "data-macs=""#{formatted_counts[:mac]}"" data-pcs=""#{formatted_counts[:pc]}"" data-thinclients=""#{formatted_counts[:tc]}"""
  end
  
  def client_pane
    devices = Array.new
    ClientDecorator.decorate(model.clients.enabled.order(:name)).each do |client| 
      devices << client.client_cell
    end
    columnize(devices)
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
end