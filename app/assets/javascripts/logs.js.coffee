reset = false

$ ->
  initPage()
  $(document).on 'page:load', initPage
  $(document).on 'page:restore', ->
    Turbolinks.visit location.href if pageIs 'logs', 'index'
  
initPage = ->  
  if pageIs 'logs'
    initInfoTogglers()
    initLogSearchForm()
    initLogsPagination()

initLogSearchForm = ->
  jQuery.datepicker.dpDiv.appendTo($('body'))
  $('.logs #start_date, .logs #end_date').each ->
    $(this).datepicker({ maxDate: '+0d' })
  
  $('.logs #submit_button').hide() if @browserSupportsPushState
  
  $('.logs #reset_form').hide()
  $(document.body).on 'click', '.logs #reset_form', resetSearchForm
  
  $(document.body).on 'submit', '.logs #search_form', ->
    $.get(this.action, serializeFilter(), null, "script")
    history.pushState(null, document.title, $('#search_form').attr('action') + serializeFilter(true)) if window.browserSupportsPushState
    false
  
  $('.logs #search_form #client').select2(
    minimumInputLength: 3
    width: 'resolve'
    allowClear: true
    ajax:
      url: '/clients.json'
      dataType: 'json'
      data: (term, page) ->
        {
          q: term
          page: page
        }
      results: (data, page) ->
        more = (page * 10) < data.total
        {
          results: data.clients
          more: more
        }
    formatResult: (client) ->
      client.name
    formatSelection: (client) ->
      client.name
    initSelection: (element, callback) ->
      val = element.val().split(',')
      callback
        id: val[0]
        name: val[1]
  )
  
  $('.logs #search_form #vm_or_user').select2(
    minimumInputLength: 3
    width: 'resolve'
    allowClear: true
    ajax:
      url: '/logs.json'
      dataType: 'json'
      data: (term, page) ->
        {
          q: term
          page_limit: 10
        }
      results: (data, page) ->
        results: data
    id: (el) ->
      "#{el.category}$$#{el.id}"
    formatResult: select2Formatter
    formatSelection: select2Formatter
    initSelection: initialSelect
  )
  
  $('.logs #search_form #site').select2(
    width: 'resolve'
  )
  
  $('.logs #search_form #type').select2(
    width: 'resolve'
  )
    
  $('.logs #search_form').on 'change', '#start_date, #end_date, #site, #type, #client, #vm_or_user', submitForm
  
  window._logs_ajax_send ||= $(document).ajaxSend (e, xhr, settings) ->
    if settings.dataType is 'script' and window.pageIs 'logs'
      $('#searching img', '.logs').fadeIn()
        
  window._logs_ajax_complete ||= $(document).ajaxComplete (e, xhr, settings) ->
    if settings.dataType is 'script' and window.pageIs 'logs'
      $('#searching img', '.logs').fadeOut()
      if reset
        reset = false
      else
        $('.logs #reset_form').show()
  
initInfoTogglers = ->
  $(document.body).on 'click', '#logs .device_info_toggler', cycleInfo
  $(document.body).on 'click', '#logs .user_toggler', cycleInfo

initLogsPagination = ->
  $(document.body).on 'click', '#logs th a, #logs .pagination a', ->
    $.getScript(this.href)
    history.pushState({getScript: true}, document.title, this.href) if window.browserSupportsPushState
    false

cycleInfo = ->
  entry = $(this)
  current = $('span:visible', entry)
  if current.next('span').length == 0
    current.hide()
    $('span:eq(0)', entry).show()
  else
    current.hide()
    current.next('span').show()

serializeFilter = (q) ->
  filteredSerialization = []
  unfilteredSerialization = $('#search_form').serialize().split('&')
  for field in unfilteredSerialization
    if field.indexOf('=') isnt (field.length - 1) and field.indexOf('utf') < 0 and field.indexOf('_') isnt 0
      filteredSerialization.push(field)
  (if q and filteredSerialization.length then '?' else '') + filteredSerialization.join('&') 
  
submitForm = ->
  $.get($('#search_form').attr('action'), serializeFilter(), null, "script")
  if window.browserSupportsPushState
    if history.state?.turbolinks?
      history.pushState({getScript: true}, document.title, $('#search_form').attr('action') + serializeFilter(true))
    else
      history.replaceState({getScript: true}, document.title, $('#search_form').attr('action') + serializeFilter(true))
  
resetSearchForm = ->
  $('#client, #vm_or_user', '#search_form').each ->
    $(this).select2('val', '')
  $('#site, #type', '#search_form').each ->
    $(this).select2('val', null)
  $('#search_form input').not('#submit_button').each ->
    $(this).val('')
  $('#search_form select').val('')
  reset = true
  $('#search_form').submit()
  $('#reset_form').hide()
  
select2Formatter = (el) ->
  icon = $('#icons .' + el.category + '_icon')
  if icon.size is 1
    '<img src="' + icon.attr('src') + '" class="result_icon" height="11" width="11" /> ' + el.id
  else
    el.id
  
initialSelect = (el, callback) ->
  val = el.val().split('$$')
  callback
    id: val[1]
    category: val[0]

  