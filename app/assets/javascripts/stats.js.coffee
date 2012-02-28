# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	initFilters()
	$('#throbbler_div').hide()
	
initFilters = ->
	$('#start_date', '#filters_list').datepicker()
	$('#end_date', '#filters_list').datepicker()
	#$('#filter_btn_div', '#filters').hide()
	#$('.selection_li:gt(0)', '#filters_list').hide()