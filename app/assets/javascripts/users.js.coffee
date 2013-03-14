# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
pstateAvailable = (history && history.pushState)

$ ->
  initPage()
  
  $(document).on 'page:load', initPage

initPage = ->
  if pageIs 'users'
    initRolesExplanationDialog()
      
initRolesExplanationDialog = ->
  $('#roles_explanation').dialog({
    autoOpen: false
    title: "Role Definitions"
    minHeight: 610
    minWidth: 1020
  })
  $(document.body).on 'click', '#roles_explanation_button, .roles_explanation_button_inline', ->
    $('#roles_explanation').dialog('open')
