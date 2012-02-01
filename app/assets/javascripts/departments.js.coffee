# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	if $('.department_summary').length > 0
		renderDepartmentCharts()
	if $('.site_summary').length > 0
		renderSiteCharts()
		
renderDepartmentCharts = ->
	$('.department_summary').each ->
		chartDiv = $('.status_chart', $(this))
		counts = {
			Available: $(this).data 'available'
			Unavailable: $(this).data 'unavailable'
			Offline: $(this).data 'offline'
		}
		total = counts["Available"] + counts["Unavailable"] + counts["Offline"]
		data = []
		colors = []
		
		if counts["Available"] > 0
			data.push(["Available", ((counts["Available"] / total) * 100).toFixed(0) * 1])
			colors.push("#5BBD5C")
		if counts["Unavailable"] > 0
			data.push(["Unavailable", ((counts["Unavailable"] / total) * 100).toFixed(0) * 1])
			colors.push("#DBC067")
		if counts["Offline"] > 0
			data.push(["Offline", ((counts["Offline"] / total) * 100).toFixed(0) * 1])
			colors.push("#D66781")
			
		if data.length is 0
			data.push(["No clients", 100.0])
			colors.push("#797982")
			
		options = 
			chart:
				renderTo: chartDiv.attr("id")
				plotBackgroundColor: null
				plotBorderWidth: null
				plotShadow: false
			title:
				text: ''
			credits:
				enabled: false
			colors: colors
			tooltip:
				formatter: ->
					if this.point.name == "No clients"
						this.point.name
					else
						this.point.name.replace("<br/>", " ") + ': ' + counts[this.point.name]
			plotOptions:
				pie:
					allowPointSelect: true
					borderWidth: 0
					cursor: "pointer"
					size: "100%"
					innerSize: "80%"
					dataLabels: 
						enabled: false
			series: [
				type: "pie"
				name: "Department Summary"
				data: data
			]
		chart = new Highcharts.Chart options
		
renderSiteCharts = ->
	$('.site_summary').each ->
		chartDiv = $('.status_chart', $(this))
		types = {
			macs: $(this).data('macs').split('-')
			pcs: $(this).data('pcs').split('-')
			tcs: $(this).data('thinclients').split('-') 
		}
		totalClients = parseInt(types["macs"][0]) + parseInt(types["pcs"][0]) + parseInt(types["tcs"][0])
		data = []
		categories = []
		colors = []
		
		if types["macs"][0] > 0
			categories.push("Macs")
			mac_statuses = []
			mac_status_data = []
			mac_colors = []
			if types["macs"][1] > 0
				mac_statuses.push("Available")
				mac_status_data.push(((types["macs"][1] / types["macs"][0]) * 100).toFixed(0) * 1)
				mac_colors.push("#5BBD5C")
			if types["macs"][2] > 0
				mac_statuses.push("Unavailable")
				mac_status_data.push(((types["macs"][2] / types["macs"][0]) * 100).toFixed(0) * 1)	
				mac_colors.push("#DBC067")
			if types["macs"][3] > 0
				mac_statuses.push("Offline")
				mac_status_data.push(((types["macs"][3] / types["macs"][0]) * 100).toFixed(0) * 1)
				mac_colors.push("#D66781")
			
			drilldown = {
				name: "Macs"
				categories: mac_statuses
				data: mac_status_data
				colors: mac_colors
			}
			type_data = {
				y: ((types["macs"][0] / totalClients) * 100).toFixed(0) * 1
				drilldown: drilldown
			}	
			data.push(type_data)
		if types["pcs"][0] > 0
			categories.push("PCs")
			pc_statuses = []
			pc_status_data = []
			pc_colors = []
			if types["pcs"][1] > 0
				pc_statuses.push("Available")
				pc_status_data.push(((types["pcs"][1] / types["pcs"][0]) * 100).toFixed(0) * 1)
				pc_colors.push("#5BBD5C")
			if types["pcs"][2] > 0
				pc_statuses.push("Unavailable")
				pc_status_data.push(((types["pcs"][2] / types["pcs"][0]) * 100).toFixed(0) * 1)	
				pc_colors.push("#DBC067")
			if types["pcs"][3] > 0
				pc_statuses.push("Offline")
				pc_status_data.push(((types["pcs"][3] / types["pcs"][0]) * 100).toFixed(0) * 1)
				pc_colors.push("#D66781")
			
			drilldown = {
				name: "PCs"
				categories: pc_statuses
				data: pc_status_data
				colors: pc_colors
			}
			type_data = {
				y: ((types["pcs"][0] / totalClients) * 100).toFixed(0) * 1
				drilldown: drilldown
			}	
			data.push(type_data)
		if types["tcs"][0] > 0
			categories.push("Thin Clients")
			tc_statuses = []
			tc_status_data = []
			tc_colors = []
			if types["tcs"][1] > 0
				tc_statuses.push("Available")
				tc_status_data.push(((types["tcs"][1] / types["tcs"][0]) * 100).toFixed(0) * 1)
				tc_colors.push("#5BBD5C")
			if types["tcs"][2] > 0
				tc_statuses.push("Unavailable")
				tc_status_data.push(((types["tcs"][2] / types["tcs"][0]) * 100).toFixed(0) * 1)	
				tc_colors.push("#DBC067")
			if types["tcs"][3] > 0
				tc_statuses.push("Offline")
				tc_status_data.push(((types["tcs"][3] / types["tcs"][0]) * 100).toFixed(0) * 1)
				tc_colors.push("#D66781")
			
			drilldown = {
				name: "Thin Clients"
				categories: tc_statuses
				data: tc_status_data
				colors: tc_colors
			}
			type_data = {
				y: ((types["tcs"][0] / totalClients) * 100).toFixed(0) * 1
				drilldown: drilldown
			}	
			data.push(type_data)

		#if data.length is 0
		#	data.push(["No clients", 100.0])
		#	colors.push("#797982")
		
		typeData = []
		typeStatusData = []
		for type, i in data
			typeData.push({
				name: categories[i]
				y: type.y
			})
			for status, j in type.drilldown.categories
				typeStatusData.push({
					name: status
					y: type.drilldown.data[j]
					color: type.drilldown.colors[j]
				})
		
		typeDataSeries = {
			name: "Client Types"
			size: '80%'
			data: typeData
		}
		typeStatusDataSeries = {
			name: "Status"
			size: '100%'
			innerSize: '80%'
			data: typeStatusData
		}
		series = [
			typeDataSeries
			typeStatusDataSeries
		]
		options = 
			chart:
				renderTo: chartDiv.attr("id")
				type: 'pie'
				plotBackgroundColor: null
				plotBorderWidth: null
				plotShadow: false
			title:
				text: ''
			credits:
				enabled: false
			colors: colors
			tooltip:
				formatter: ->
					if this.point.name == "No clients"
						this.point.name
					else
						this.point.name.replace("<br/>", " ") + ': ' + this.y
			plotOptions:
				pie:
					allowPointSelect: true
					borderWidth: 0
					cursor: "pointer"
					size: "100%"
			series: series
		chart = new Highcharts.Chart options