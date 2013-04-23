<% if @chart_type == "column" %>
  options = 
    chart:
      renderTo: "chart"
      defaultSeriesType: "column"
      backgroundColor: null
    credits:
      enabled: false
    title:
      text: "Total <%= raw @client_types %> Logins Per Hour"
    xAxis:
      categories: <%= raw @data.keys.as_json %>
      labels:
        rotation: -45
        align: "right"
    series:
      [
        data: <%= raw @data.values.as_json %>
        name: "Logins"
      ]
    tooltip:
      formatter: ->
        '<b>' + this.series.name.replace("<br/>", " ") + '</b>(' + this.x.replace("<br/>", ", ") + '): ' + this.y
    yAxis:
      title:
        text: "Logins"
    legend:
      enabled: false
  
  <% if @subtitle.present? %>
  options.subtitle =
    text: "<%= @subtitle %>"
  <% end %>
  
  chart = new Highcharts.Chart options
<% elsif @chart_type == "pie" %>
  options = 
    chart:
      renderTo: "chart"
      plotBackgroundColor: null
      plotBorderWidth: null
      plotShadow: false
      backgroundColor: null
    credits:
      enabled: false
    title:
      text: "Total <%= raw @client_types %> Logins Per Hour"
    tooltip:
      formatter: ->
        this.point.name.replace("<br/>", " ") + ": " + this.y + '%'
    plotOptions:
      pie:
        allowedPointSelect: true
        cursor: "pointer"
        dataLabels: 
          enabled: true
          color: "#A6D3FD"
          connectorColor: "#C0C0C0"
    series: 
      [
        type: "pie"
        data: <%= raw @data.as_json %>
        name: "Logins"
      ]
      
  <% if @subtitle.present? %>
  options.subtitle =
    text: "<%= @subtitle %>"
  <% end %>
  
  chart = new Highcharts.Chart options
<% elsif @chart_type == "line" %>
  options = 
    chart:
      renderTo: "chart"
      defaultSeriesType: "line"
      backgroundColor: null
    credits:
      enabled: false
    title:
      text: "Total <%= raw @client_types %> Logins Per Hour"
    xAxis:
      categories: <%= raw @data.keys.as_json %>
      labels:
        rotation: -45
        align: "right"
    series:
      [
        data: <%= raw @data.values.as_json %>
        name: "Logins"
      ]
    tooltip:
      formatter: ->
        '<b>' + this.series.name.replace("<br/>", " ") + '</b>(' + this.x.replace("<br/>", ", ") + '): ' + this.y
    yAxis:
      title:
        text: "Logins"
      min: 0
    legend:
      enabled: false
  
  <% if @subtitle.present? %>
  options.subtitle =
    text: "<%= @subtitle %>"
  <% end %>
  
  chart = new Highcharts.Chart options
<% end %>