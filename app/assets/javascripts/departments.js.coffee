# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	if $('.department_summary').length > 0
		renderDepartmentCharts()

renderDepartmentCharts = ->
	$('.department_summary').each ->
		chartDiv = $('.status_chart', $(this))
		available = $(this).data 'available'
		unavailable = $(this).data 'unavailable'
		offline = $(this).data 'offline'
		total = available + unavailable + offline
		data = []
		colors = []
		if available > 0
			data.push(["Available", ((available / total) * 100).toFixed(0) * 1])
			colors.push("#5BBD5C")
		if unavailable > 0
			data.push(["Unavailable", ((unavailable / total) * 100).toFixed(0) * 1])
			colors.push("#DBC067")
		if offline > 0
			data.push(["Offline", ((offline / total) * 100).toFixed(0) * 1])
			colors.push("#D66781")
		options = 
			chart:
				renderTo: chartDiv.attr("id")
				plotBackgroundColor: null
				plotBorderWidth: null
				plotShadow: false
			title:
				text: "Computing Sites"
			credits:
				enabled: false
			colors: colors
			tooltip:
				formatter: ->
					this.point.name.replace("<br/>", " ") + ': ' + this.y + "%"
			plotOptions:
				pie:
					allowPointSelect: true
					borderWidth: 0
					cursor: "pointer"
					size: "100%"
					innerSize: "80%"
					dataLabels: 
						enabled: false
						distance: 0
						color: "#437D99"
						connectorColor: Highcharts.theme.textColor or "#000000"
						formatter: ->
							'<b>' + this.point.name + '</b><br/>' + this.y + '%'
			series: [
				type: "pie"
				name: "Department Summary"
				data: data
			]
		chart = new Highcharts.Chart options