options = 
	chart:
		renderTo: "chart"
		defaultSeriesType: "line"
		marginRight: 200
		backgroundColor: null
	credits:
		enabled: false
	title:
		text: "Total Logins Per Day"
	xAxis:
		categories: <%= raw @data[:categories].as_json %>
	series: <%= raw @data[:sites].to_json %>
	tooltip:
		formatter: ->
			'<b>' + this.series.name.replace("<br/>", " ") + '</b>(' + this.x + '): ' + this.y
	yAxis:
		title:
			text: "Logins"
		min: 0
	legend:
		layout: "vertical"
		align: "right"
		verticalAlign: "middle"
		x: -10
		borderWidth: 0
		style:
			overflow: "scroll"
		
if options.xAxis.categories.length > 20 
	options.xAxis.labels =
		step: Math.round(options.xAxis.categories.length / 10)

if options.series.length > 20
	options.chart.marginRight = 50
	options.chart.height = 500
	options.legend = 
		itemWidth: 180
		align: "center"

<% if @subtitle.present? %>
options.subtitle =
	text: "<%= @subtitle %>"
<% end %>

chart = new Highcharts.Chart options