pstateAvailable = (history && history.pushState)
initialURL = location.href
popped = false

jQuery ->
	initMenu()
	initBestInPlace()
	initButtons()
	initPopstate()
	setTimeout(hideFlashes, 4000)

initMenu = ->
	resizeMenu()
	$(window).bind 'resize', resizeMenu
	$('#main_nav ul.menu ul').hide()
	$('.site_group').each ->
		$(this).hover ->
			$('ul', this).toggle('blind')

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
		$(window).bind("popstate", ->
			if location.href == initialURL and not popped
				return
			popped = true
			$.getScript(location.href)
		)

hideFlashes = ->
	$('.flash').each ->
		$(this).fadeOut 'slow', ->
			$(this).remove()

