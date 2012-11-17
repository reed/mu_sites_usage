# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
pstateAvailable = (history && history.pushState)
reset = false

jQuery ->
	if $('body').data('controller') is 'clients'
		if $('body').data('action') is 'index'
			initClientsSearchForm()
			initClientsPagination()

initClientsSearchForm = ->
	$('.clients #reset_form').hide().click(resetSearchForm)
	$('.clients #search_form').submit ->
			$.get(this.action, serializeFilter(), null, "script")
			history.pushState(null, document.title, $('#search_form').attr('action') + "?" + serializeFilter()) if pstateAvailable
			false
			
	$('.clients #search_form input').keyup(submitForm)
	$('.clients #search_form #type, .clients #search_form #site').change(submitForm)
	
	$('.clients #submit_button').hide() if pstateAvailable
		
	$(document).ajaxComplete ->
		if reset
			reset = false
		else
			$('.clients #reset_form').show()

initClientsPagination = ->
	$('#clients th a, #clients .pagination a').live("click", ->
		$.getScript(this.href)
		history.pushState(null, document.title, this.href) if pstateAvailable
		false
	)
	
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