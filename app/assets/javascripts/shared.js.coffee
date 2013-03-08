window.pstateAvailable = (history && history.pushState)
window.initialURL = location.href
window.popped = false
window.timeouts = []

jQuery ->
	initMenu()
	initBestInPlace()
	initButtons()
	#initPopstate()
	addTimeout(hideFlashes, 4000)
	$(document).on 'page:change', clearAllTimeouts

$(document).on 'page:load', ->
	initMenu()
	initBestInPlace()
	initButtons()
	addTimeout(hideFlashes, 4000)


	
addTimeout = (func, delay) ->
	window.timeouts.push setTimeout(func, delay)

initMenu = ->
	resizeMenu()
	$(window).bind 'resize', resizeMenu
	$('#main_nav ul.menu ul').hide()
	initAccordion()
	addTimeout ( ->
		$('.site_group:has(.selected)').each ->
			$('ul', this).show('blind', {easing: 'easeInOutCubic'}).addClass('shown')
	), 1000

initAccordion = ->
	$('.site_group').on 'mouseenter', ->
		submenu = $('ul', this)
		unless submenu.hasClass('shown')
			$('.site_group').off 'mouseenter'
			submenu.show('blind', {easing: 'easeInOutCubic'}, initAccordion)
			$('ul.shown', '.site_group').hide('blind', {easing: 'easeInOutCubic'}).removeClass('shown')
			submenu.addClass('shown')
	
resizeMenu = ->
	if $('#main_nav').height() > ($(window).height() - 20)
		site_list = $('#main_nav ul.menu ul')
		if site_list.size() is 1
			site_list.height($(window).height() - ($('#main_nav').height() - site_list.height()) - 40)
			site_list.css('overflowY', 'scroll')
	
initBestInPlace = ->
	$('.best_in_place').best_in_place()
	
initButtons = ->
	$('.buttonset').buttonset()
	$('a.button, input[type="button"], input[type="submit"]').each ->
		$(this).button()
	
initPopstate = ->
	if pstateAvailable
		$(window).bind("popstate", (e) ->
			e.preventDefault()
			if location.href == initialURL and not popped
				return
			popped = true
			$.getScript(location.href)
		)

hideFlashes = ->
	$('.flash').each ->
		$(this).fadeOut 'slow', ->
			$(this).remove()

clearAllTimeouts = ->
	clearTimeout(timeout) for timeout in window.timeouts
	window.timeouts = []
	
jQuery ->
  console.log "dom ready"

$(document).bind 'page:change', ->
  console.log "page changed"

$(document).bind 'page:fetch', ->
  console.log "page fetched"

$(document).bind 'page:load', ->
  console.log "page loaded"

$(document).bind 'page:restore', ->
  console.log "page restored"
