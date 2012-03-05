options = 
	chart:
		renderTo: "chart"
		zoomType: "x"
		marginRight: 150
	credits:
		enabled: false
	title:
		text: "Historical Snapshots"
	xAxis:
		labels: 
			y: 20
			formatter: ->
				Highcharts.dateFormat("%b %e, '%y", this.value) + '<br/>' + Highcharts.dateFormat('%l:%M %p', this.value)
		type: "datetime"
	series: []
	plotOptions: 
		areaspline:
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
			stacking: "normal"
	tooltip:
		shared: true
		formatter: ->
			s = '<b>' + Highcharts.dateFormat('%B %e, %Y %l:%M %p', this.x) + '</b>'
			$.each(this.points, (i, point) ->
				s += '<br/>' + point.series.name + ': ' + point.y
			)
			s
	yAxis:
		title:
			text: "Devices (by status)"
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
	type: "areaspline"
options.series.push(series)
<% end %>
		
<% if @subtitle.present? %>
options.subtitle =
	text: "<%= @subtitle %>"
<% end %>

chart = new Highcharts.Chart options