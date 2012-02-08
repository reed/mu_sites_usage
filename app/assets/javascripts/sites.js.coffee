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
	$('.toggle_button').one('click', showDetails)

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
	
showDetails = ->
	pane = $(this).parent().next('.site_pane')
	detailsHeader = $('<div class="details_header"></div>')
	$('<div>Hostname</div>').appendTo(detailsHeader)
	$('<div>MAC Address</div>').appendTo(detailsHeader)
	$('<div>IP Address</div>').appendTo(detailsHeader)
	$('<div>User</div>').appendTo(detailsHeader)
	#$('<div>Connected VM</div>').appendTo(detailsHeader)
	$('<div>Status</div>').appendTo(detailsHeader)
	devices = $('.device', pane)
	newHeight = 20 * (devices.length + 1)
	pane.animate({height: newHeight}, 500)
	pane.css('paddingTop', '0px')
	pane.html(detailsHeader).append(columnizeDetails(devices))
	#$('.light-right', pane).remove()
	$('.user:contains("Unknown User")', pane).text("").addClass('empty_details')
	#$('.vm:contains("Unknown VM")', pane).text("").addClass('empty-details')
	$('.device_detail span', pane).not('.user-toggler').show()
	$('.device_column:eq(0)', pane).css('width', '170px')
	$('.device_column:gt(0)', pane).each ->
		$(this).addClass('centered').css('width', '121px')
		$('span:not(".user-toggler")', this).addClass('details')
	$('.device_column:eq(3), .details_header div:eq(3)', pane).css('width', '211px')
	$('.device_column:eq(4), .details_header div:eq(4)', pane).css('width', '141px')
	$('.device_column:eq(5), .details_header div:eq(5)', pane).css('width', '386px')
	#$('.user-toggler', pane).click(toggleUser);
	#$(this).text('Basic').one('click', function(){
	#	$(this).text('Details').one('click', showDetails);
	#	var pane = $(this).parent().next('.sitePane');
	#	update(pane);
	#});
	
columnizeDetails = (devices) ->
	columns = []
	columnCount = 5
	columns[j] = [] for j in [0..columnCount - 1]
	#for (j = 0; j < columnCount; j++){
	#	columns[j] = [];
	#}
	for device, i in devices
		dev = $(device)
		status = dev.data("status") + '_detail'
		img = $('<div>').append($('img:first-child', dev).clone()).remove().html()
		for j in [0..columnCount - 1]
			span = $('<div>').append($('span:not(".user-toggler, .vm"):eq(' + j + ')', dev).clone()).remove().html()
			if j == 0
				columns[j].push('<div class="device_detail ' + status + '">' + img + span + '</div>')
			else
				columns[j].push('<div class="device_detail ' + status + '">' + span + '</div>')
	
			
	# for (i = 0; i < tcs.length; i++){
	# 	tc = $(tcs[i]);
	# 
	# 	status = tc.attr('data-status') + '_detail';
	# 	img = $('<div>').append($('img', tc).clone()).remove().html();
	# 	for (j = 0; j < columnCount; j++){
	# 		span = $('<div>').append($('span:not(".userToggler"):eq(' + j + ')', tc).clone()).remove().html();
	# 		if (j == 0){
	# 			columns[j].push('<div class="thinclient-detail ' + status + '">' + img + span + '</div>');
	# 		}else{
	# 			columns[j].push('<div class="thinclient-detail ' + status + '">' + span + '</div>');
	# 		}
	# 	}
	# }
	html = ''
	for column in columns
		col = '<div class="device_column">' + column.join('') + '</div>'
		html = html + col
	
	html	
	# for (i = 0; i < columns.length; i++){
	# 	col = '<div class="thinclient_list_pane">' + columns[i].join('') + '</div>';
	# 	html = html + col;
	# }
	# return html;
	