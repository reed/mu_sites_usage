# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  initPage()
  
  $(document).on 'page:load', initPage
  $(document).on 'page:restore', ->
    Turbolinks.visit location.href if pageIs 'users', 'index'

initPage = ->
  if pageIs 'users'
    initRolesExplanationDialog()
    
  if pageIs 'users', 'index'
    initUsersPagination()
      
initRolesExplanationDialog = ->
  $('#roles_explanation').dialog({
    autoOpen: false
    title: "Role Definitions"
    minHeight: 610
    minWidth: 1020
  })
  $(document.body).on 'click', '#roles_explanation_button, .roles_explanation_button_inline', ->
    $('#roles_explanation').dialog('open')

initUsersPagination = ->
  $(document.body).on 'click', '#users th a:not(.dialog_open), #users .pagination a', ->
    $.getScript(this.href)
    history.pushState({getScript: true}, document.title, this.href) if window.browserSupportsPushState
    false