# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	initFilters()
	$('#toggle_filters_btn').click(toggleFilters)
	$('#throbbler_div, #ajax_error').hide()
	$('#throbbler_div').ajaxStart ->
		$('#chart').empty()
		$('#ajax_error').hide()
		$(this).show()
	$('#throbbler_div').ajaxSuccess ->
		$(this).hide()
	$('#throbbler_div').ajaxError ->
		$(this).hide()
		$('#ajax_error').show()
	$('#filter_form').submit ->
		toggleFilters() if $('#toggle_filters_btn').text() is "Hide Filters"
	$('#reload').click ->
		$('#filter_form').submit()
	
initFilters = ->
	dates = $('#start_date, #end_date', '#filters_list').datepicker({
		maxDate: "+0d",
		onSelect: (selectedDate) ->
			$(this).addClass('date_input_selected')
			option = if this.id is "start_date" then "minDate" else "maxDate"
			instance = $(this).data("datepicker")
			date = $.datepicker.parseDate(instance.settings.dateFormat or $.datepicker._defaults.dateFormat, selectedDate, instance.settings)
			dates.not(this).datepicker("option", option, date)
	})
	$('#start_date, #end_date', '#filters_list').change( ->
		$(this).val("").removeClass('date_input_selected').datepicker("setDate", null)
		dates.not(this).datepicker("option", "minDate", null) if this.id is "start_date" 
		dates.not(this).datepicker("option", "maxDate", '+0d') if this.id is "end_date" 
	)
	$('#filter_btn_dv', '#filters').hide()
	$('.selection_li:gt(0)', '#filters_list').hide()
	$('input[name="chart_select"]').click(chartSelected)
	$('input[name="total_select"], input[name="average_select"], input[name="concurrent_select"]').click(subSelected)
	$('input[name="client_type_select[]"]').click(clientTypeSelected)
	$('input[name="site_select[]"]').click(siteSelected)
	$('input[name="type_select"]').click(typeSelected)
	
toggleFilters = ->
	btn = $('#toggle_filters_btn')
	if btn.text() == "Hide Filters"
		$('#filters').hide("blind", 1000)
		btn.text("Show Filters")
	else
		$('#filters').show("blind", 1000)
		btn.text("Hide Filters")

chartSelected = ->
	switch this.id
		when 'total_logins' then showFilters('chart_selection', ['total_selection'])
		when 'average_logins' then showFilters('chart_selection', ['average_selection'])
		when 'concurrent_logins' then showFilters('chart_selection', ['concurrent_selection'])
		when 'historical_snapshots' then showFilters('chart_selection', ['date_range_selection', 'site_selection'])

subSelected = ->
	g1 = ['date_range_selection', 'client_type_selection', 'site_selection']
	g2 = ['date_range_selection', 'client_type_selection', 'type_selection']
	g3 = ['date_range_selection', 'site_selection']
	switch this.id
		when 'per_site', 'per_month_and_site', 'per_week_and_site', 'per_day_and_site', 'per_hour_and_site'
			showFilters('total_selection', g1)
		when 'per_year', 'per_month', 'per_week', 'per_day', 'per_hour'
			showFilters('total_selection', g2)
		when 'daily', 'weekly', 'monthly'
			showFilters('average_selection', g1)
		when 'average_per_site', 'average_overall', 'maximum_per_site', 'maximum_overall'
			showFilters('concurrent_selection', g3)

clientTypeSelected = ->
	if this.id is "client_type_all"
		$(this).attr('checked', 'checked') if not $(this).attr('checked')
		$('#client_type_selection input:gt(0)').removeAttr('checked')
	else
		$('#client_type_all', '#client_type_selection').removeAttr('checked')
	$('#client_type_selection').buttonset('refresh')
	
siteSelected = ->
	if this.id is "site_all"
		$('#site_selection input:gt(0)').removeAttr('checked')
	else
		$('#site_all', '#site_selection').removeAttr('checked')
	$('#site_selection').buttonset('refresh')
	showFilters('site_selection', ['type_selection'])

typeSelected = ->
	showFilters('type_selection', ['filter_btn'])
				
showFilters = (selected, toShow) ->
	targetFilters = $('#' + selected + '_li').nextAll('.selection_li')
	
	resetFilters(targetFilters)
	
	targetFilters = targetFilters.add('#filter_btn_dv')
	
	hideQueue = targetFilters.filter(':visible').filter( ->
		name = this.id.substr(0, this.id.length - 3)
		($.inArray(name, toShow) < 0)
	)
	showQueue = targetFilters.filter(':hidden').filter( ->
		name = this.id.substr(0, this.id.length - 3)
		($.inArray(name, toShow) > -1)
	)
	
	animateFilters($.makeArray(hideQueue), $.makeArray(showQueue))
 
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
			$('#start_date').datepicker("setDate", null).removeClass('date_input_selected')
			$('#end_date').datepicker("setDate", null).removeClass('date_input_selected')
		else if filterName is "client_type_selection"
			$('#client_type_selection input')
				.removeAttr('checked')
				.button({disabled: false})
			$('#client_type_all').attr('checked', 'checked')
			$('#client_type_selection').buttonset('refresh')
		else
			$('#' + filterName + ' input')
				.removeAttr('checked')
				.button({disabled: false})
			$('#' + filterName).buttonset('refresh')
	chartSelect = $('input[name="chart_select"]:checked')
	chartSubselect = $('input[name="total_select"]:checked, input[name="average_select"]:checked, input[name="concurrent_select"]:checked')
	if chartSubselect.length > 0
		switch chartSubselect.val()
			when "per-site", "per-year", "daily", "weekly", "monthly"
				restrictTypeOptions('line')
			when "per-month-and-site", "per-week-and-site"
				restrictTypeOptions('pie')
			when "per-day-and-site", "per-hour-and-site", "average-per-site", "average-overall", "maximum-per-site", "maximum-overall"
				restrictTypeOptions(["pie", "column"])
	else if chartSelect.length > 0 and chartSelect.val() is "historical_snapshots"
		restrictTypeOptions(["pie", "column"])
				
restrictTypeOptions = (types) ->
	if $.isArray(types)
		$.each(types, (index, value) ->
			$('#type_selection #type_' + value).button({disabled: true})
		)
	else
		$('#type_selection #type_' + types).button({disabled: true})
	$('#type_selection').buttonset('refresh')
