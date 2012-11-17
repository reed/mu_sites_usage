# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
pstateAvailable = (history && history.pushState)
#initialURL = location.href
#popped = false
reset = false

jQuery ->
	if $('body').data('controller') is 'logs'
		initInfoTogglers()
		initLogSearchForm()
		initLogsPagination()

initLogSearchForm = ->
	$('.logs #start_date, .logs #end_date').each ->
		$(this).datepicker({ maxDate: '+0d' })
	
	$('.logs #submit_button').hide() if pstateAvailable
	
	$('.logs #reset_form').hide().click(resetSearchForm)
	
	$('.logs #search_form').submit ->
		$.get(this.action, serializeFilter(), null, "script")
		history.pushState(null, document.title, $('#search_form').attr('action') + "?" + serializeFilter()) if pstateAvailable
		false
	
	$('.logs #search_form #client').select2(
		minimumInputLength: 3
		width: 'resolve'
		allowClear: true
		ajax:
			url: '/clients.json'
			dataType: 'json'
			data: (term, page) ->
				{
					q: term
					page: page
				}
			results: (data, page) ->
				more = (page * 10) < data.total
				{
					results: data.clients
					more: more
				}
		formatResult: (client) ->
			client.name
		formatSelection: (client) ->
			client.name
		initSelection: (element) ->
			val = element.val().split(',')
			{
				id: val[0]
				name: val[1]
			}	
	)
	
	$('.logs #search_form #vm_or_user').select2(
		minimumInputLength: 3
		width: 'resolve'
		allowClear: true
		ajax:
			url: '/logs.json'
			dataType: 'json'
			data: (term, page) ->
				{
					q: term
					page_limit: 10
				}
			results: (data, page) ->
				results: data
		id: (el) ->
			"#{el.category}$$#{el.id}"
		formatResult: select2Formatter
		formatSelection: select2Formatter
		initSelection: initialSelect
	)
	
	$('.logs #search_form #site').select2(
		width: 'resolve'
	)
	
	$('.logs #search_form #type').select2(
		width: 'resolve'
	)
		
	$('#start_date, #end_date, #site, #type, #client, #vm_or_user', '.logs #search_form').change(submitForm)
	
	$(document).ajaxSend (e, xhr, settings) ->
		if settings.dataType is 'script'
			$('#searching img', '.logs').fadeIn()
				
	$(document).ajaxComplete (e, xhr, settings) ->
		if settings.dataType is 'script'
			$('#searching img', '.logs').fadeOut()
			if reset
				reset = false
			else
				$('.logs #reset_form').show()
	
initInfoTogglers = ->
	$('#logs .device_info_toggler').live('click', cycleInfo)
	$('#logs .user_toggler').live('click', cycleInfo)

initLogsPagination = ->
	$('#logs th a, #logs .pagination a').live("click", ->
		$.getScript(this.href)
		history.pushState(null, document.title, this.href) if pstateAvailable
		false
	)

cycleInfo = ->
	entry = $(this)
	current = $('span:visible', entry)
	if current.next('span').length == 0
		current.hide()
		$('span:eq(0)', entry).show()
	else
		current.hide()
		current.next('span').show()

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
	$('#client, #vm_or_user', '#search_form').each ->
		$(this).select2('val', '')
	$('#site, #type', '#search_form').each ->
		$(this).select2('val', null)
	$('#search_form input').not('#submit_button').each ->
		$(this).val('')
	$('#search_form select').val('')
	reset = true
	$('#search_form').submit()
	$('#reset_form').hide()
	
select2Formatter = (el) ->
	icon = $('#icons .' + el.category + '_icon')
	if icon.size is 1
		'<img src="' + icon.attr('src') + '" class="result_icon" height="11" width="11" /> ' + el.id
	else
		el.id
	
initialSelect = (el) ->
	val = el.val().split('$$')	
	{
		id: val[1]
		category: val[0]
	}
	