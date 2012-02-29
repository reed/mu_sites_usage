options = 
	chart:
		renderTo: "chart"
		defaultSeriesType: "column"
	credits:
		enabled: false
	title:
		text: "Total Logins Per Site"
	xAxis:
		categories: <%= raw @data.keys.as_json %>
	series:
		[
			data: <%= raw @data.values.as_json %>
			name: "Logins"
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

#$('#filters').hide("clip", "slow", ->
chart = new Highcharts.Chart options
#)
#$('.stats').append('<pre id="return_json"></pre>')
#$('#return_json').text(JSON.stringify(options, undefined, 3))	
		
