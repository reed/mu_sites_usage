options = 
	chart:
		renderTo: "chart"
		zoomType: "x"
		backgroundColor: null
	credits:
		enabled: false
	title:
		text: "Average Concurrent Logins - Overall"
	xAxis:
		labels: 
			formatter: ->
				Highcharts.dateFormat('%I:%M %p', this.value)
		type: "datetime"
	series:
		[
			data: <%= raw @data.as_json %>
			name: "Average Concurrent Logins"
			type: "spline"
			pointStart: Date.UTC(2012, 0, 1, 0, 0, 0)
			pointInterval: 5 * 60 * 1000
		]
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
		enabled: false

<% if @subtitle.present? %>
options.subtitle =
	text: "<%= @subtitle %>"
<% end %>

chart = new Highcharts.Chart options