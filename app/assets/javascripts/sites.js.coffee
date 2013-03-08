pstateAvailable = (history && history.pushState)
initialLoad = true

$ ->
	initPage()

	$(document).on 'page:load', initPage

class SiteList
	constructor: ->
		@container = $('#site_list')
		@sites = {}
			
	load: ->
		ids = @container.data('sites')
		unless ids.length is 0
			first_id = ids.shift()
			@container.data('sites', ids)
			$('.refresh_button', @sites[first_id].header).click()
			@load()
	
	addSites: ->
		$('.site_block').each (index, site) =>
			@add $(site)
				
	add: (container) ->
		site = new Site container
		@sites[site.id] = site
		
	remove: (id) ->
		@sites[id].hide()
		delete @sites[id]
		
	build: ->
		$('#main_throbbler img').show 'slide', {direction: 'right'}, =>
			link = $(this)
			url = link.data('url')
			$.get(url, (data) ->
				newSite = window.site_list.add $(data)
				newSite.container.hide().prependTo('#site_list').slideDown( ->
						$('#main_throbbler img').hide 'slide', {direction: 'right'}
				)
				history.replaceState(window.history.state, document.title, location.href + '/' + newSite.name) if pstateAvailable
			)
		
	refresh: ->
		unless initialLoad
			$('#main_throbbler img').show 'slide', {direction: 'right'}
			showing = true
		if $(this).attr('id') is 'refresh_image'
			$('.summary').hide()
			$('.throbbler_container').show()
			siteNames = []
			siteNames.push site.name for id, site of window.site_list.sites
			siteName = siteNames.join '/'
		else
			site = window.site_list.sites[$(this).parent().data('site')]
			siteName = site.name
			site.container.find('.summary').hide()
			site.throbbler.show() unless initialLoad
		$.getJSON('/sites/refresh/' + siteName, (data) ->
			window.site_list.sites[id].refresh(clients) for id, clients of data
			$('#main_throbbler img').hide 'slide', {direction: 'right'} if showing?
		)

class Site
	constructor: (@container) ->
		@devices = @container.find('.device')
		@header = @container.find('.site_header')
		@pane = @container.find('.site_pane')
		@toggle_button = @container.find('.toggle_button')
		@id = @container.data 'site'
		@name = @container.data 'site-name'
		@menu_link = $('a', "#site_#{@id}")
		
		@setupThrobbler()
		@setupDevices() 
		@updateMenu 'init'
		@bindCallbacks()
		
	setupThrobbler: ->
		@throbbler = @container.find('.throbbler_container')
		@throbbler.hide()
		@throbbler.ajaxError =>
			@throbbler.hide()
			@header.find('.summary').show()
	
	setupDevices: ->
		for device in @devices
			$('span:gt(0)', device).not('.user_toggler').hide()
			$('.uid', device).hide()
			$(device).click cycleInfo
	
	bindCallbacks: ->
		@container.find('.hide_button').one 'click', =>
			@menu_link.unbind 'click'
			window.site_list.remove @id
		@menu_link.one 'click', =>
			window.site_list.remove @id
		@container.find('.refresh_button').click(window.site_list.refresh)
		@toggle_button.one('click', @showDetails)
			
	updateMenu: (action) ->
		if action is 'init'
			@menu_link.removeClass('show').addClass('selected')
		else if action is 'remove'
			@menu_link.removeClass('selected').addClass('show').one('click', window.site_list.build)
	
	hide: ->
		@container.animate {height: '0px'}, 500, =>
			@container.remove()
			@updateMenu 'remove'
		history.replaceState(history.state, document.title, location.href.replace("/" + @name, "")) if pstateAvailable
			
	refresh: (clients) ->
		newClients = $(clients).css 'opacity', '0'
		@devices = newClients.find('.device')
		@setupDevices()
		if @devices.length > 0
			newHeight = (26 * Math.ceil(@devices.length / 5)) + 2
			newHeight = newHeight + 'px'
		else
			$('.toggle_button, .refresh_button', @header).hide()
		@pane.html newClients
		@updateCounts()
		@throbbler.hide()
		@header.find('.summary').show()
		if @toggle_button.text() == 'Basic'
			@toggle_button.unbind('click').one('click', @showDetails).click()
		else
			@pane.animate({height: newHeight}, 500) if newHeight?
			newClients.animate({opacity: 1}, 500)
		if initialLoad
			initialLoad = false if window.site_list.container.data('sites').length is 0
		
		
	updateCounts: ->
		@header.find('.available_count').text @pane.find('.available').length
		@header.find('.unavailable_count').text @pane.find('.unavailable').length
		@header.find('.offline_count').text @pane.find('.offline').length
			
	showDetails: =>
		detailsHeader = $('<tr class="details_table_header"></tr>')
		$('<th>Hostname</th>').appendTo(detailsHeader)
		$('<th>MAC Address</th>').appendTo(detailsHeader)
		$('<th>IP Address</th>').appendTo(detailsHeader)
		$('<th>User</th>').appendTo(detailsHeader)
		$('<th>Status</th>').appendTo(detailsHeader)
		detailsTable = $('<table class="details_table"></table>')
		detailsTable.append(detailsHeader).append(columnizeDetails(@devices)).css('opacity', '0')
		@pane.html(detailsTable)
	
		newHeight = @pane.height()
		newHeight = newHeight + "px"
		rowCount = $('.device_row', @pane).length
	
		$('.user:contains("Unknown User")', @pane).text("").addClass('empty_details')
		$('.device_detail span', @pane).not('.user_toggler').show()
		$('.device_row', @pane).each ->
			$('td:gt(0)', this).each ->
				$(this).addClass('centered')
				$('span:not(".user_toggler")', this).addClass('details')
		$('.user_toggler', @pane).click(toggleUser)
		h = $('.details_table', @pane).height()
		@pane.animate({height: h}, rowCount * 15)
		$('.details_table', @pane).animate({opacity: 1}, 1500)
		$('.vm', @pane).hide()
		$('.name_toggler span', @pane).click(toggleName)
		@toggle_button.text('Basic').one('click', @hideDetails)
		
	hideDetails: =>
		@toggle_button.text('Details').one('click', @showDetails)
		@container.find('.refresh_button').click()

class AutoUpdater
	constructor: ->
		$('.auto_update').click @change	
		@refresher = setInterval "$('#refresh_image').click()", 300000
		if $.cookie('auto_update') isnt null
			@change $('.auto_update[data-interval="' + $.cookie('auto_update') + '"]')
	
	change: (event) =>
		target = if event.target? then event.target else event
		interval = $(target).data('interval')
		if interval is 'off'
			clearInterval @refresher
		else
			@set interval
		$('.selected_interval').removeClass 'selected_interval'
		$(target).addClass 'selected_interval'
		$.cookie('auto_update', interval, {path: '/'})
		
	set: (min) ->
		msec = min * 60000
		clearInterval @refresher
		@refresher = setInterval "$('#refresh_image').click()", msec
			
cycleInfo = ->
	device = $(this)
	current = $('span.cycle:visible', device)
	if current.next('span.cycle').length == 0
		current.hide()
		$('span.cycle:eq(0)', device).show()
	else
		current.hide()
		current.next('span.cycle').show()


initPage = ->
	if $('body').data('controller') is 'sites'
	# 	if $('body').data('action') is 'index'
	# 		initNameFilterExplanationDialog()
	# 		initSitesPagination()
	# 	
	# 	if $('body').data('action') in ['new', 'edit', 'create', 'update']
	# 		initNameFilterExplanationDialog()
	# 		initNameFilterChecker()
		
		if $('body').data('action') is 'show'
			$('.initial_throbbler').filter(':last').one 'load', initSitesShow
					
initSitesShow = ->
	initialLoad = true
	window.site_list = new SiteList
	window.site_list.addSites()
	
	$('#main_throbbler img').hide()
	$('#main_throbbler').ajaxError ->
		$('img', this).hide('slide', {direction: 'right'})
	$('#site_list').sortable({ placeholder: "ui-state-active", forcePlaceholderSize: true, handle: '.site_header' })
	$('.show').one('click', window.site_list.build)
	$('#refresh_image').click(window.site_list.refresh)
	window.site_list.load() if window.site_list.sites?
	new AutoUpdater

initSitesPagination = ->
	$('#sites th a:not(.dialog_open), #sites .pagination a').live("click", ->
		$.getScript(this.href)
		history.pushState(null, document.title, this.href) if pstateAvailable
		false
	)
	
initNameFilterExplanationDialog = ->
	$('#name_filter_explanation').dialog({
		autoOpen: false
		title: "Name Filters"
		minWidth: 600
	})
	$('.name_filter_explanation_button_inline').live("click", ->
		$('#name_filter_explanation').dialog('open')
	)

initNameFilterChecker = ->
	$('#searching', '#client_matches').hide()
	$('#client_matches').hide()
	$('#reset_name_filter').hide().live('click', resetNameFilter)
	$('#site_name_filter').live("change", checkForFilterMatches)
	if $('#site_name_filter').size() is 1 and $('#site_name_filter').val()?.length isnt 0
		orig_filter = $('#site_name_filter').val()
		checkForFilterMatches() 
		$('#site_name_filter').data('original_filter', orig_filter)
	
checkForFilterMatches = ->
	$('#client_matches').show()
	$('#searching', '#client_matches').show()
	$('#reset_name_filter').show() if $('#site_name_filter').data('original_filter')?
	$('#matches', '#client_matches').empty()
	params = {filter: $('#site_name_filter').val()}
	url = $('#client_matches').data('url') + '?' + $.param(params)
	$.getScript(url)

resetNameFilter = ->
	$('#site_name_filter').val($('#site_name_filter').data('original_filter')).change()
	$('#reset_name_filter').hide()

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
