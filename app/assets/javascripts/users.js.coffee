$ ->
  initPage()
  
  $(document)
    .on('page:load', initPage)
    .on 'page:restore', ->
      Turbolinks.visit location.href if pageIs 'users', 'index'

initPage = ->
  if pageIs 'users'
    initRolesExplanationDialog()
    
  if pageIs 'users', 'index'
    initUsersPagination()
      
initRolesExplanationDialog = ->
  $rolesExplanation = $('#roles_explanation')
  $rolesExplanation.dialog
    autoOpen: false
    title: "Role Definitions"
    minHeight: 610
    minWidth: 1020
  $(document.body).on 'click', '#roles_explanation_button, .roles_explanation_button_inline', ->
    $rolesExplanation.dialog 'open'

initUsersPagination = ->
  $(document.body).on 'click', '#users th a:not(.dialog_open), #users .pagination a', ->
    $.getScript(this.href)
    history.pushState({getScript: true}, document.title, this.href) if window.browserSupportsPushState
    false
