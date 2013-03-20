options = 
  chart:
    renderTo: "chart"
    zoomType: "x"
    marginRight: 200
    backgroundColor: null
  credits:
    enabled: false
  title:
    text: "Average Concurrent Logins Per Site"
  xAxis:
    labels: 
      formatter: ->
        Highcharts.dateFormat('%I:%M %p', this.value)
    type: "datetime"
  series: []
  plotOptions: 
    spline:
      lineWidth: 1
      marker:
        enabled: false
        states:
          hover:
            enabled: true
            radius: 5
      shadow: false
      states:
        hover:
          lineWidth: 1
  tooltip:
    shared: true
    formatter: ->
      s = '<b>' + Highcharts.dateFormat('%l:%M %p', this.x) + '</b>'
      $.each(this.points, (i, point) ->
        s += '<br/>' + point.series.name + ': ' + point.y
      )
      s
  yAxis:
    title:
      text: "Concurrent Logins (avg)"
    min: 0
    allowDecimals: true
  legend:
    layout: "vertical"
    align: "right"
    verticalAlign: "middle"
    x: -10
    borderWidth: 0

<% @data.each_pair do |s, d| %>
series = 
  data: <%= raw d.as_json %>
  name: <%= raw s.to_json %>
  type: "spline"
  pointStart: Date.UTC(2012, 0, 1, 0, 0, 0)
  pointInterval: 5 * 60 * 1000
options.series.push(series)
<% end %>

if options.series.length > 20
  options.chart.marginRight = 50
  options.chart.height = 800
  options.legend = 
    itemWidth: 180
    align: "center"
    
<% if @subtitle.present? %>
options.subtitle =
  text: "<%= @subtitle %>"
<% end %>

chart = new Highcharts.Chart options