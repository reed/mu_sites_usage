<% if @chart_type == "column" %> 
  options = 
    chart:
      renderTo: "chart"
      defaultSeriesType: "column"
      backgroundColor: null
    credits:
      enabled: false
    title:
      text: "Total <%= raw @client_types %> Logins Per Site"
    xAxis:
      categories: <%= raw @data.keys.as_json %>
    series: [
      name: "Logins"
      data: <%= raw @data.values.as_json %>
    ]
    tooltip: 
      formatter: ->
        '<b>' + this.series.name.replace("<br/>", " ") + '</b>(' + this.x.replace("<br/>", " ") + '): ' + this.y
    yAxis: 
      title:
        text: "Logins"
    legend:
      enabled: false

  <% if @subtitle.present? %>
  options.subtitle =
    text: "<%= @subtitle %>"
  <% end %>

  <% if @data.size > 15 %>
  options.xAxis.labels =
    rotation: -45
    align: "right"
  <% elsif @data.size > 10 %>
  options.xAxis.labels = 
    staggerLines: 2
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
      text: "Total <%= raw @client_types %> Logins Per Site"
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
<% end %>
