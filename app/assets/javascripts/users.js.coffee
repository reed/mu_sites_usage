# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
	$('.buttonset').buttonset()
	$('.best_in_place').best_in_place()
	$('#roles_explanation').dialog({
		autoOpen: false
		title: "Role Definitions"
		minHeight: 610
		minWidth: 1020
	})
	$('#roles_explanation_button, .roles_explanation_button_inline').click ->
		$('#roles_explanation').dialog('open')