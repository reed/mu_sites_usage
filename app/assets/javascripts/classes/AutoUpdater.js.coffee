class @AutoUpdater
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
			
