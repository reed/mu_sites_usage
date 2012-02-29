# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	initFilters()
	$('#toggle_filters_btn').click(toggleFilters)
	$('#throbbler_div').hide()
	$('#throbbler_div').ajaxStart ->
		$('#chart').empty()
		$(this).show()
	$('#throbbler_div').ajaxSuccess ->
		$(this).hide()
	$('#filter_form').submit ->
		$.get this.action, $('#filter_form').serialize(), "script"
		false
		# $.getJSON this.action, $('#filter_form').serialize(), (data) ->
		# 	chart = new Highcharts.Chart data
		# 	$('.stats').append('<pre id="return_json"></pre>')
		# 	$('#return_json').text(JSON.stringify(data, undefined, 3))
		# false
	
initFilters = ->
	$('#start_date', '#filters_list').datepicker()
	$('#end_date', '#filters_list').datepicker()
	#$('#filter_btn_div', '#filters').hide()
	#$('.selection_li:gt(0)', '#filters_list').hide()
	
toggleFilters = ->
	btn = $('#toggle_filters_btn')
	if btn.text() == "Hide Filters"
		$('#filters').hide("blind", 1000)
		btn.text("Show Filters")
	else
		$('#filters').show("blind", 1000)
		btn.text("Hide Filters")
	
		