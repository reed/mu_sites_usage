<% if @chart_type == "column" %>
	options = 
		chart:
			renderTo: "chart"
			defaultSeriesType: "column"
		credits:
			enabled: false
		title:
			text: "Average Weekly Logins Per Site"
		xAxis:
			categories: <%= raw @data.keys.as_json %>
		series:
			[
				data: <%= raw @data.values.as_json %>
				name: "Average Logins Per Week"
			]
		tooltip:
			formatter: ->
				'<b>' + this.series.name.replace("<br/>", " ") + '</b>(' + this.x + '): ' + this.y
		yAxis:
			title:
				text: "Logins (avg)"
		legend:
			enabled: false

	<% if @data.size > 15 %>
	options.xAxis.labels =
		rotation: -45
		align: "right"
	<% elsif @data.size > 10 %>
	options.xAxis.labels = 
		staggerLines: 2
	<% end %>
	
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
		credits:
			enabled: false
		title:
			text: "Average Weekly Logins Per Site"
		tooltip:
			formatter: ->
				this.point.name.replace("<br/>", " ") + ": " + this.y + '%'
		plotOptions:
			pie:
				allowedPointSelect: true
				cursor: "pointer"
				dataLabels: 
					enabled: true
					color: "#C0C0C0"
					connectorColor: "#C0C0C0"
		series: 
			[
				type: "pie"
				data: <%= raw @data.as_json %>
				name: "Average Logins Per Week"
			]
			
	<% if @subtitle.present? %>
	options.subtitle =
		text: "<%= @subtitle %>"
	<% end %>
	
	chart = new Highcharts.Chart options
<% end %>