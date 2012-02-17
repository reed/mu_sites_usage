# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
pstateAvailable = (history && history.pushState)
initialURL = location.href
popped = false
reset = false

jQuery ->
	$('.clients #reset_form').hide().click(resetSearchForm)
		
	$('#clients th a, #clients .pagination a').live("click", ->
		$.getScript(this.href)
		history.pushState(null, document.title, this.href) if pstateAvailable
		false
	)
	
	$('.clients #search_form').submit ->
			$.get(this.action, serializeFilter(), null, "script")
			history.pushState(null, document.title, $('#search_form').attr('action') + "?" + serializeFilter()) if pstateAvailable
			false
			
	$('.clients #search_form input').keyup(submitForm)
	$('.clients #search_form #type, .clients #search_form #site').change(submitForm)
	
	if pstateAvailable
		$(window).bind("popstate", ->
			if location.href == initialURL and not popped
				return
			popped = true
			$.getScript(location.href)
		)
		$('.clients #submit_button').hide()
		
	$(document).ajaxComplete ->
		if reset
			reset = false
		else
			$('.clients #reset_form').show()
	
serializeFilter = ->
	filteredSerialization = []
	unfilteredSerialization = $('#search_form').serialize().split('&')
	for field in unfilteredSerialization
		if field.indexOf('=') isnt (field.length - 1)
			filteredSerialization.push(field)
	filteredSerialization.join('&')	
	
submitForm = ->
	$.get($('#search_form').attr('action'), serializeFilter(), null, "script")
	history.replaceState(null, document.title, $('#search_form').attr('action') + "?" + serializeFilter()) if pstateAvailable
	
resetSearchForm = ->
	$('#search_form input').not('#submit_button').each ->
		$(this).val('')
	$('#search_form select').val('')
	reset = true
	$('#search_form').submit()
	$('#reset_form').hide()