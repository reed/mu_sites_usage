# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	initPage()
	
	$(document).on 'page:load', initPage

initPage = ->
	if $('body').data('controller') is 'departments'
		if $('body').data('action') is 'index'
			initDepartmentChartTooltips()
			
		if $('body').data('action') is 'show'
			initSiteChartTooltips()

initDepartmentChartTooltips = ->
	if $('.department_summary').length > 0
		initHover()
		$('.department_summary').each ->
			deptDiv = $(this)
			counts = {
				Available: $(this).data 'available'
				Unavailable: $(this).data 'unavailable'
				Offline: $(this).data 'offline'
			}
			@formatTooltip = (data) ->
				ttip = $('.tooltip', deptDiv)
				ttip.removeClass('tooltip_Available tooltip_Unavailable tooltip_Offline')
				if data.point.name == "No clients"
					ttip.html(data.point.name)
				else
					ttip.html(counts[data.point.name] + ' ' + data.point.name).addClass('tooltip_' + data.point.name)
				return false

initHover = ->
	if $('.highcharts-container').length > 0
		$('.highcharts-container').each ->
			$(this).hover ->
				deptDiv = $(this).closest('.department_summary')
				$('.tooltip', deptDiv).toggleClass('visible')
	else
		setTimeout ( ->
			initHover()
		), 200
		
initSiteChartTooltips = ->
	if $('.site_summary').length > 0
		$('.site_summary').each ->
			@formatTooltip = (data, total) ->
				if total is 0
					"No Computers"
				else if data.series.name == "Client Types"
					data.point.name.replace("<br/>", " ") + ': ' + ((data.percentage / 100) * total).toFixed(0)
				else
					data.point.name + ": " + ((data.percentage / 100) * total).toFixed(0)