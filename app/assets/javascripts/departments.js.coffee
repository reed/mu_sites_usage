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
		data = [
			["Available", ((available / total) * 100).toFixed(0) * 1]
			["Unavailable", ((unavailable / total) * 100).toFixed(0) * 1]
			["Offline", ((offline / total) * 100).toFixed(0) * 1]
		]
		options = 
			chart:
				renderTo: chartDiv.attr("id")
				plotBackgroundColor: null
				plotBorderWidth: null
				plotShadow: false
			title:
				text: ""
			credits:
				enabled: false
			tooltip:
				formatter: ->
					this.point.name.replace("<br/>", " ") + ': ' + this.y + "%"
			plotOptions:
				pie:
					allowPointSelect: true
					cursor: "pointer"
					dataLabels: 
						enabled: false
						distance: 100
						color: Highcharts.theme.textColor or "#000000"
						connectorColor: Highcharts.theme.textColor or "#000000"
						formatter: ->
							'<b>' + this.point.name + '</b>: ' + this.y + '%'
			series: [
				type: "pie"
				name: "Department Summary"
				data: data
			]
		chart = new Highcharts.Chart options