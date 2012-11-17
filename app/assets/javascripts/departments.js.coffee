# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	if $('body').data('controller') is 'departments'
		if $('body').data('action') is 'index'
			renderDepartmentCharts()
			
		if $('body').data('action') is 'show'
			renderSiteCharts()
		
	
renderDepartmentCharts = ->
	if $('.department_summary').length > 0
		$('.department_summary').each ->
			chartDiv = $('.status_chart', $(this))
			deptDiv = $(this)
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
					backgroundColor: null 
				title:
					text: ''
				credits:
					enabled: false
				colors: colors
				tooltip:
					formatter: ->
						ttip = $('.tooltip', deptDiv)
						ttip.removeClass('tooltip_Available tooltip_Unavailable tooltip_Offline')
						if this.point.name == "No clients"
							ttip.html(this.point.name)
						else
							ttip.html(counts[this.point.name] + ' ' + this.point.name).addClass('tooltip_' + this.point.name)
						return false
				plotOptions:
					pie:
						borderWidth: 0
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
		$('.highcharts-container').each ->
			$(this).hover ->
				deptDiv = $(this).closest('.department_summary')
				$('.tooltip', deptDiv).toggleClass('visible')
		
renderSiteCharts = ->
	if $('.site_summary').length > 0
		$('.site_summary').each ->
			chartDiv = $('.status_chart', $(this))
			types = {
				Macs: $(this).data('macs').split('-')
				PCs: $(this).data('pcs').split('-')
				"Thin Clients": $(this).data('thinclients').split('-') 
			}
			totalClients = parseInt(types["Macs"][0]) + parseInt(types["PCs"][0]) + parseInt(types["Thin Clients"][0])
			data = []
			categories = []
			colors = []
			type_colors = {
				Macs: "#437D99"
				PCs: "#64BBE6"
				"Thin Clients": "#87C7E6"
			}
		
			for type, typeCounts of types
				if typeCounts[0] > 0
					categories.push(type)
					type_statuses = []
					type_status_data = []
					status_colors = []
					if typeCounts[1] > 0
						type_statuses.push("Available " + type)
						type_status_data.push((typeCounts[1] / totalClients) * 100)
						status_colors.push("#5BBD5C")
					if typeCounts[2] > 0
						type_statuses.push("Unavailable " + type)
						type_status_data.push((typeCounts[2] / totalClients) * 100) 	
						status_colors.push("#DBC067")
					if typeCounts[3] > 0
						type_statuses.push("Offline " + type)
						type_status_data.push((typeCounts[3] / totalClients) * 100) 
						status_colors.push("#D66781")

					drilldown = {
						name: type
						categories: type_statuses
						data: type_status_data
						colors: status_colors
					}
					type_data = {
						y: (typeCounts[0] / totalClients) * 100
						color: type_colors[type]
						drilldown: drilldown
					}	
					data.push(type_data)
		
			if data.length is 0
				noClients = true
				drilldown = {
					name: "No clients"
					categories: ["No clients"]
					data: [100.0]
					colors: [Highcharts.Color("#797982").brighten(0.2).get()]
				}
				type_data = {
					y: 100.0
					color: "#797982"
					drilldown: drilldown
				}
				data.push(type_data)
			else
				noClients = false
			
			typeData = []
			typeStatusData = []
			for type, i in data
				typeData.push({
					name: categories[i]
					y: type.y
					color: type.color
				})
				for status, j in type.drilldown.categories
					typeStatusData.push({
						name: status
						y: type.drilldown.data[j]
						color: type.drilldown.colors[j]
					})
	
			typeDataSeries = {
				name: "Client Types"
				size: '85%'
				innerSize: '10%'
				data: typeData
				dataLabels: {
					color: '#001621'
					distance: -60
					style: {
						fontSize: '16px'
					}
					formatter: ->
						if noClients
							'<b>No computers</b>'
						else
							'<b>' + this.point.name.replace(" ", "</b><br/><b>") + '</b>'
				}
			}
			typeStatusDataSeries = {
				name: "Status"
				size: '100%'
				innerSize: '85%'
				data: typeStatusData
				dataLabels: {
					enabled: false
				}
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
					backgroundColor: null
				title:
					text: ''
				credits:
					enabled: false
				colors: colors
				tooltip:
					formatter: ->
						if noClients
							"No Computers"
						else if this.series.name == "Client Types"
							this.point.name.replace("<br/>", " ") + ': ' + ((this.percentage / 100) * totalClients).toFixed(0)
						else
							this.point.name + ": " + ((this.percentage / 100) * totalClients).toFixed(0)
				plotOptions:
					pie:
						borderWidth: 1
						borderColor: "#001621"
						size: "100%"
				series: series
			chart = new Highcharts.Chart options