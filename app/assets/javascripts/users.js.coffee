# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
pstateAvailable = (history && history.pushState)

jQuery ->
	if $('body').data('controller') is 'users'
		initRolesExplanationDialog()
		
		if $('body').data('action') is 'index'
			initUsersPagination()
			
initRolesExplanationDialog = ->
	$('#roles_explanation').dialog({
		autoOpen: false
		title: "Role Definitions"
		minHeight: 610
		minWidth: 1020
	})
	$('#roles_explanation_button, .roles_explanation_button_inline').live("click", ->
		$('#roles_explanation').dialog('open')
	)

initUsersPagination = ->
	$('#users th a:not(.dialog_open), #users .pagination a').live("click", ->
		$.getScript(this.href)
		history.pushState(null, document.title, this.href) if pstateAvailable
		false
	)