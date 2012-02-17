# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
pstateAvailable = (history && history.pushState)

jQuery ->
	$('#start_date, #end_date').each ->
		$(this).datepicker()
	$('#logs th a, #logs .pagination a').live("click", ->
		$.getScript(this.href)
		history.pushState(null, document.title, this.href) if pstateAvailable
		false
	)
	
	$('#search_form').submit ->
		$.get(this.action, $(this).serialize(), null, "script")
		history.pushState(null, document.title, $('#search_form').attr('action') + "?" + $('#search_form').serialize()) if pstateAvailable
		false
		
	$('#search_form input').keyup ->
		$.get($('#search_form').attr('action'), $('#search_form').serialize(), null, "script")
		history.replaceState(null, document.title, $('#search_form').attr('action') + "?" + $('#search_form').serialize()) if pstateAvailable
	
	setUpDeviceInfoCycler()
	
	if pstateAvailable
		$(window).bind("popstate", ->
			$.getScript(location.href)
		)
		
	$(document).ajaxComplete ->
		setUpDeviceInfoCycler()

setUpDeviceInfoCycler = ->
	$('.device_info_toggler').each ->
		$('span:gt(0)', this).hide()
		$(this).click(cycleDeviceInfo)
	
cycleDeviceInfo = ->
	entry = $(this)
	current = $('span:visible', entry)
	if current.next('span').length == 0
		current.hide()
		$('span:eq(0)', entry).show()
	else
		current.hide()
		current.next('span').show()
