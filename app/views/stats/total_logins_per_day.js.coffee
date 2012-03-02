<% if @chart_type == "column" %>
	options = 
		chart:
			renderTo: "chart"
			defaultSeriesType: "column"
		credits:
			enabled: false
		title:
			text: "Total Logins Per Day"
		xAxis:
			categories: <%= raw @data.keys.as_json %>
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
			text: "Total Logins Per Day"
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
		credits:
			enabled: false
		title:
			text: "Total Logins Per Day"
		xAxis:
			categories: <%= raw @data.keys.as_json %>
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
			
	<% if @data.size > 20 %>
	options.xAxis.labels =
		step: Math.round(options.xAxis.categories.length / 10)
	<% end %>
	
	<% if @subtitle.present? %>
	options.subtitle =
		text: "<%= @subtitle %>"
	<% end %>
	
	chart = new Highcharts.Chart options
<% end %>