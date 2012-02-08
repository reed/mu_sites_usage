# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery -> 
	$('.best_in_place').best_in_place()
	$('.throbbler_container', '.sites').hide()
	$('.device').each ->
		$('span:gt(0)', this).hide()
		$(this).click(cycleInfo)
	$('.site_header', '.sites').each ->
		siteID = $(this).data('site')
		$('a', '#site_' + siteID).removeClass("show").addClass("selected")
	$('.hide_button, .selected').one('click', hideSite)
	$('.refresh_button').click(refreshSite)
	$('.show').one('click', buildSite)

cycleInfo = ->
	device = $(this)
	current = $('span.cycle:visible', device)
	if current.next('span.cycle').length == 0
		current.hide()
		$('span.cycle:eq(0)', device).show()
	else
		current.hide()
		current.next('span.cycle').show()
	
hideSite = ->
	if $(this).hasClass('hide_button')
		header = $(this).parent()
		pane = $(this).parent().next('.site_pane')
		siteID = header.data('site')
	else
		siteID = $(this).data('site')
		header = $('.site_header[data-site=' + siteID + ']')
		pane = $('.site_pane[data-site=' + siteID + ']')

	pane.animate({height: '0px'}, 500, ->
		$(this).remove()
	)
	header.animate({height: '0px'}, 500, ->
		$(this).remove()
		$('a', '#site_' + siteID).removeClass("selected").addClass('show').one('click', buildSite)
	)

buildSite = ->
	link = $(this)
	url = $(this).data('url')
	siteID = $(this).data('site')
	$.get(url, (data) ->
		newSite = $(data)
		$('.throbbler_container', newSite).hide()
		$('.device', newSite).each ->
			$('span:gt(0)', this).hide()
			$(this).click(cycleInfo)
		newSite.appendTo('#container')
		header = $('.site_header[data-site=' + siteID + ']')
		$('.hide_button', header).one('click', hideSite)
		$('.refresh_button', header).click(refreshSite)
		link.removeClass('show').addClass('selected').one('click', hideSite)
	)
	
refreshSite = ->
	header = $(this).parent()
	$('.summary', header).hide()
	$('.throbbler_container', header).show()
	pane = $(this).parent().next('.site_pane')
	siteName = pane.data('site-name')
	$.getJSON('/sites/refresh/' + siteName, (data) ->
		$.each(data, (id, clients) -> 
			siteHeader = $('.site_header[data-site=' + id + ']')
			sitePane = $('.site_pane[data-site=' + id + ']')
			newClients = $(clients)
			$('.device', newClients).each ->
				$('span:gt(0)', this).hide()
				$(this).click(cycleInfo)
			sitePane.html(newClients)
			$('.available_count', siteHeader).text($('.available', sitePane).length)
			$('.unavailable_count', siteHeader).text($('.unavailable', sitePane).length)
			$('.offline_count', siteHeader).text($('.offline', sitePane).length)
			$('.throbbler_container', siteHeader).hide()
			$('.summary', siteHeader).show()
		)
	)