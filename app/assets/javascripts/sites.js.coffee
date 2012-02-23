# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
pstateAvailable = (history && history.pushState)
initialURL = location.href
popped = false
t = ""

jQuery -> 
	# Index
	$('.best_in_place').best_in_place()
	$('#sites th a, #sites .pagination a').live("click", ->
		$.getScript(this.href)
		history.pushState(null, document.title, this.href) if pstateAvailable
		false
	)
	# Show
	$('.throbbler_container', '.sites').hide()
	$('#site_list').sortable({ placeholder: "ui-state-active", forcePlaceholderSize: true })
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
	$('#refresh_image').click(refreshSite)
	$('.auto_update').click ->
		if $(this).data('interval') is "off"
			clearInterval(t)
		else
			setUpdate($(this).data('interval'))
		$('.selected_interval').removeClass("selected_interval")
		$(this).addClass("selected_interval")
		$.cookie("auto_update", $(this).data('interval'))

	t = setInterval("$('#refresh_image').click()", 300000)
	if $.cookie('auto_update') isnt null
		$('.auto_update[data-interval="' + $.cookie('auto_update') + '"]').click()
		
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
		siteBlock = $(this).parents('.site_block')
		siteID = siteBlock.data('site')
		siteName = siteBlock.data('site-name')
	else
		siteID = $(this).data('site')
		siteName = $(this).data('site-name')
		siteBlock = $('.site_block[data-site=' + siteID + ']')

	siteBlock.animate({height: '0px'}, 500, ->
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
		newSite.hide().appendTo('#site_list').slideDown()
		header = $('.site_header[data-site=' + siteID + ']')
		$('.hide_button', header).one('click', hideSite)
		$('.refresh_button', header).click(refreshSite)
		$('.toggle_button', header).one('click', showDetails)
		link.removeClass('show').addClass('selected').one('click', hideSite)
		history.pushState(null, document.title, location.href + '/' + siteName) if pstateAvailable
	)
		
refreshSite = ->
	if $(this).attr('id') is "refresh_image"
		$('.summary').hide()
		$('.throbbler_container').show()
		siteNames = []
		$('.site_block').each ->
			siteNames.push $(this).data('site-name')
		siteName = siteNames.join('/')	
	else
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
			#sitePane.css('height', newHeight)
			sitePane.html(newClients)
			$('.available_count', siteHeader).text($('.available', sitePane).length)
			$('.unavailable_count', siteHeader).text($('.unavailable', sitePane).length)
			$('.offline_count', siteHeader).text($('.offline', sitePane).length)
			$('.throbbler_container', siteHeader).hide()
			$('.summary', siteHeader).show()
			if $('.toggle_button', siteHeader).text() == "Basic"
				$('.toggle_button', siteHeader).unbind('click').one('click', showDetails).click()
		)
		updateTime()
	)

showDetails = ->
	pane = $(this).parent().next('.site_pane')
	detailsHeader = $('<tr class="details_table_header"></tr>')
	$('<th>Hostname</th>').appendTo(detailsHeader)
	$('<th>MAC Address</th>').appendTo(detailsHeader)
	$('<th>IP Address</th>').appendTo(detailsHeader)
	$('<th>User</th>').appendTo(detailsHeader)
	$('<th>Status</th>').appendTo(detailsHeader)
	detailsTable = $('<table class="details_table"></table>')
	devices = $('.device', pane)
	detailsTable.append(detailsHeader).append(columnizeDetails(devices))
	pane.html(detailsTable)
	newHeight = pane.height()
	newHeight = newHeight + "px"
	$('.details_table', pane).hide()
	$('.details_table', pane).show('blind', 500)
	$('.user:contains("Unknown User")', pane).text("").addClass('empty_details')
	$('.device_detail span', pane).not('.user_toggler').show()
	$('.device_row', pane).each ->
		$('td:gt(0)', this).each ->
			$(this).addClass('centered')
			$('span:not(".user_toggler")', this).addClass('details')
	$('.user_toggler', pane).click(toggleUser)
	$('.vm', pane).hide()
	$('.name_toggler span', pane).click(toggleName)
	$(this).text('Basic').one('click', ->
		$(this).text('Details').one('click', showDetails)
		pane = $(this).parent().next('.site_pane')
		$('.refresh_button', $(this).parent()).click()
	)

columnizeDetails = (devices) ->
	rows = []
	columnCount = 5
	rows[j] = [] for j in [0..devices.length - 1]
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
					rows[i].push('<td class="device_detail name_toggler ' + status + '">' + light + typeIcon + span + vm + '</td>')
				else
					rows[i].push('<td class="device_detail ' + status + '">' + light + typeIcon + span + '</td>')
			else
				rows[i].push('<td class="device_detail ' + status + '">' + span + '</td>')

	html = ''
	for row in rows
		r = '<tr class="device_row">' + row.join('') + '</tr>'
		html = html + r
	html	

toggleUser = ->
	container = $(this).parent('.details')
	$('.user_toggler', container).each ->
		$(this).toggle()
		
toggleName = ->
	container = $(this).parent('.name_toggler')
	$('span', container).each ->
		$(this).toggle()

setUpdate = (min) ->
	msec = min * 60000
	clearInterval(t)
	t = setInterval("$('#refresh_image').click()", msec)
		
updateTime = ->
	now = new Date
	hours = now.getHours()
	minutes = now.getMinutes()
	month = now.getMonth() + 1
	day = now.getDate()
	year = now.getFullYear();
	
	ampm = if hours > 11 then 'pm' else 'am'
	hours = hours - 12 if hours > 12
	hours = 12 if hours is 0
	minutes = "0" + minutes if minutes < 10
	year -= 2000
	
	formatted = month + "/" + day + "/" + year + " " + hours + ":" + minutes + " " + ampm
	origColor = $('#last_updated').css("color")
	
	$('#last_updated').text(formatted).css("color", "#FFFFFF").animate({ color: origColor })
	