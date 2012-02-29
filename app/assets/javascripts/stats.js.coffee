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
	$('#filter_btn_div', '#filters').hide()
	$('.selection_li:gt(0)', '#filters_list').hide()
	
toggleFilters = ->
	btn = $('#toggle_filters_btn')
	if btn.text() == "Hide Filters"
		$('#filters').hide("blind", 1000)
		btn.text("Show Filters")
	else
		$('#filters').show("blind", 1000)
		btn.text("Hide Filters")
	
animateFilters = (toHide, toShow) ->
	if toHide.length > 0
		next = toHide.pop()
		$('#' + next.id).hide('slide', {direction: 'up'}, 500)
		window.setTimeout( ->
			animateFilters(toHide, toShow)
		, 300)
	else if toShow.length > 0
		next = toShow.shift()
		$('#' + next.id).show('slide', {direction: 'up', easing: 'easeOutBounce'}, 1000)
		window.setTimeout( ->
			animateFilters(toHide, toShow)
		, 300)

resetFilters = (filters) ->
	filters.each ->
		filterID = this.id
		filterName = filterID.substr(0, filterID.length - 3)
		if filterName is "date_range_selection"
			$('#start_date').datepicker("setDate", null)
			$('#end_date').datepicker("setDate", null)
		else
			$('#' + filterName + ' input')
				.removeAttr('checked')
				.button({disabled: false})
			$('#' + filterName).buttonset('refresh')
	chartSelect = $('input[name="chart_select"]:checked')
	chartSubselect = $('input[name="total_subselect"]:checked, input[name="average_subselect"]:checked, input[name="concurrent_subselect"]:checked')
	if chartSubselect.length > 0
		switch chartSubselect.val()
			when "per-site", "per-year", "daily", "weekly", "monthly"
				restrictTypeOptions('line')
			when "per-month-and-site", "per-week-and-site"
				restrictTypeOptions('pie')
			when "per-day-and-site", "per-hour-and-site", "average-per-site", "average-overall", "maximum-per-site", "maximum-overall"
				restrictTypeOptions(["pie", "column"])
				
restrictTypeOptions = (types) ->
	if $.isArray(types)
		$.each(types, (index, value) ->
			$('#type_selection #type_' + value).button({disabled: true})
		)
	else
		$('#type_selection #type_' + types).button({disabled: true})
	$('#type_selection').buttonset('refresh')
