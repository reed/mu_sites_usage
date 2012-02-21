# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
pstateAvailable = (history && history.pushState)
initialURL = location.href
popped = false

jQuery -> 
	$('.best_in_place').best_in_place()
	$('.throbbler_container', '.sites').hide()
	$('.device').each ->
		$('span:gt(0)', this).not('.user_toggler').hide()
		$('.uid', this).hide()
		$(this).click(cycleInfo)
	$('.site_header', '.sites').each ->
		siteID = $(this).data('site')
		$('a', '#site_' + siteID).removeClass("show").addClass("selected")
	$('.hide_button, .selected').one('click', hideSite)
	$('.refresh_button').click(refreshSite)
	$('.show').one('click', buildSite)
	$('.toggle_button').one('click', showDetails)
	$('#sites th a, #sites .pagination a').live("click", ->
		$.getScript(this.href)
		history.pushState(null, document.title, this.href) if pstateAvailable
		false
	)
	
	if pstateAvailable
		$(window).bind("popstate", ->
			if location.href == initialURL and not popped
				return
			popped = true
			$.getScript(location.href)
		)

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
		siteName = header.data('site-name')
	else
		siteID = $(this).data('site')
		siteName = $(this).data('site-name')
		header = $('.site_header[data-site=' + siteID + ']')
		pane = $('.site_pane[data-site=' + siteID + ']')

	pane.animate({height: '0px'}, 500, ->
		$(this).remove()
	)
	header.animate({height: '0px'}, 500, ->
		$(this).remove()
		$('a', '#site_' + siteID).removeClass("selected").addClass('show').one('click', buildSite)
	)
	history.pushState(null, document.title, location.href.replace("/" + siteName, "")) if pstateAvailable

buildSite = ->
	link = $(this)
	url = $(this).data('url')
	siteID = $(this).data('site')
	siteName = $(this).data('site-name')
	$.get(url, (data) ->
		newSite = $(data)
		$('.throbbler_container', newSite).hide()
		$('.device', newSite).each ->
			$('span:gt(0)', this).not('.user_toggler').hide()
			$('.uid', this).hide()
			$(this).click(cycleInfo)
		newSite.appendTo('#container')
		header = $('.site_header[data-site=' + siteID + ']')
		$('.hide_button', header).one('click', hideSite)
		$('.refresh_button', header).click(refreshSite)
		$('.toggle_button', header).one('click', showDetails)
		link.removeClass('show').addClass('selected').one('click', hideSite)
		history.pushState(null, document.title, location.href + '/' + siteName) if pstateAvailable
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
				$('span:gt(0)', this).not('.user_toggler').hide()
				$('.uid', this).hide()
				$(this).click(cycleInfo)
			newHeight = (26 * Math.ceil($('.device', newClients).length / 5)) + 2
			newHeight = newHeight + "px"
			sitePane.css('height', newHeight)
			sitePane.html(newClients)
			$('.available_count', siteHeader).text($('.available', sitePane).length)
			$('.unavailable_count', siteHeader).text($('.unavailable', sitePane).length)
			$('.offline_count', siteHeader).text($('.offline', sitePane).length)
			$('.throbbler_container', siteHeader).hide()
			$('.summary', siteHeader).show()
			if $('.toggle_button', siteHeader).text() == "Basic"
				$('.toggle_button', siteHeader).unbind('click').one('click', showDetails).click()
		)
	)
	
showDetails = ->
	pane = $(this).parent().next('.site_pane')
	detailsHeader = $('<div class="details_header"></div>')
	$('<div>Hostname</div>').appendTo(detailsHeader)
	$('<div>MAC Address</div>').appendTo(detailsHeader)
	$('<div>IP Address</div>').appendTo(detailsHeader)
	$('<div>User</div>').appendTo(detailsHeader)
	$('<div>Status</div>').appendTo(detailsHeader)
	devices = $('.device', pane)
	newHeight = 20 * (devices.length + 1)
	pane.animate({height: newHeight}, 500)
	pane.html(detailsHeader).append(columnizeDetails(devices))
	$('.user:contains("Unknown User")', pane).text("").addClass('empty_details')
	$('.device_detail span', pane).not('.user_toggler').show()
	$('.device_column:eq(0)', pane).css('width', '200px')
	$('.device_column:gt(0)', pane).each ->
		$(this).addClass('centered').css('width', '140px')
		$('span:not(".user_toggler")', this).addClass('details')
	$('.device_column:eq(3), .details_header div:eq(3)', pane).css('width', '230px')
	$('.device_column:eq(4), .details_header div:eq(4)', pane).css('width', '440px')
	$('.user_toggler', pane).click(toggleUser)
	$('.vm', pane).hide()
	$('.name_toggler span', pane).click(toggleName)
	$(this).text('Basic').one('click', ->
		$(this).text('Details').one('click', showDetails)
		pane = $(this).parent().next('.site_pane')
		$('.refresh_button', $(this).parent()).click()
	)
	
columnizeDetails = (devices) ->
	columns = []
	columnCount = 5
	columns[j] = [] for j in [0..columnCount - 1]
	for device, i in devices
		dev = $(device)
		status = dev.data("status") + '_detail'
		light = $('<div>').append($('img:eq(0)', dev).clone()).remove().html()
		typeIcon = $('<div>').append($('.' + dev.data('type'), '#type_icon_reserve').clone()).remove().html()
		for j in [0..columnCount - 1]
			span = $('<div>').append($('span:not(".user_toggler, .vm"):eq(' + j + ')', dev).clone()).remove().html()
			if j == 0
				if $('.vm', dev).text() != "Unknown VM"
					vm = $('<div>').append($('.vm', dev).clone()).remove().html()
					columns[j].push('<div class="device_detail name_toggler ' + status + '">' + light + typeIcon + span + vm + '</div>')
				else
					columns[j].push('<div class="device_detail ' + status + '">' + light + typeIcon + span + '</div>')
			else
				columns[j].push('<div class="device_detail ' + status + '">' + span + '</div>')
	
	html = ''
	for column in columns
		col = '<div class="device_column">' + column.join('') + '</div>'
		html = html + col
	html	

toggleUser = ->
	container = $(this).parent('.details')
	$('.user_toggler', container).each ->
		$(this).toggle()
		
toggleName = ->
	container = $(this).parent('.name_toggler')
	$('span', container).each ->
		$(this).toggle()