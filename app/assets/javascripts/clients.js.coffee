reset = false

$ ->
  initPage()

  $(document).on 'page:load', initPage
  $(document).on 'page:restore', ->
    Turbolinks.visit location.href if pageIs 'clients', 'index'

initPage = ->
  if pageIs 'clients', 'index'
    initClientsSearchForm()
    initClientsPagination()

initClientsSearchForm = ->
  $clients = $('.clients')
  $resetForm = $clients.find('#reset_form')

  $resetForm.hide() if formIsReset()
  $clients.find('#submit_button').hide() if @browserSupportsPushState
  
  $(document.body)
    .on('click', '.clients #reset_form', resetSearchForm)
    .on('submit', '.clients #search_form', ->
      $.get(this.action, serializeFilter(), null, "script")
      history.pushState(null, document.title, $('#search_form').attr('action') + serializeFilter(true)) if window.browserSupportsPushState
      false)   
    .on('keyup', '.clients #search_form input', submitForm)
    .on 'change', '.clients #search_form #type, .clients #search_form #site', submitForm
  
  window._clientsAjaxComplete ||= $(document).ajaxComplete ->
    if window.pageIs 'clients', 'index'
      if reset
        reset = false
      else
        $('.clients #reset_form').show()

initClientsPagination = ->
  $(document.body).on 'click', '#clients th a, #clients .pagination a', ->
    $.getScript(this.href)
    history.pushState({getScript: true}, document.title, this.href) if window.browserSupportsPushState
    false

formIsReset = ->
  $('#search_form input').each ->
    return false if $(this).val().length > 0
  return false if $('#search_form select').val().length > 0
  true
  
serializeFilter = (q) ->
  filteredSerialization = []
  unfilteredSerialization = $('#search_form').serialize().split('&')
  for field in unfilteredSerialization
    if field.indexOf('=') isnt (field.length - 1) and field.indexOf('utf') < 0 and field.indexOf('_') isnt 0
      filteredSerialization.push(field)
  (if q and filteredSerialization.length then '?' else '') + filteredSerialization.join('&') 
  
submitForm = ->
  action = $('#search_form').attr 'action'
  $.get(action, serializeFilter(), null, "script")
  if window.browserSupportsPushState
    if history.state?.turbolinks?
      history.pushState({getScript: true}, document.title, action + serializeFilter(true))
    else
      history.replaceState({getScript: true}, document.title, 'action' + serializeFilter(true))
  
resetSearchForm = ->
  $searchForm = $('#search_form')
  $resetForm = $('#reset_form')
  
  $searchForm.find('input').not('#submit_button').each ->
    $(this).val('')
  $searchForm.find('select').val('')
  reset = true
  $searchForm.submit()
  $resetForm.hide()
