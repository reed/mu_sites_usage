# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
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
