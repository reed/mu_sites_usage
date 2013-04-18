reset = false
resetting = false

$ ->
  initPage()
  $(document)
    .on('page:load', initPage)
    .on 'page:restore', ->
      Turbolinks.visit location.href if pageIs 'logs', 'index'
  
initPage = ->  
  if pageIs 'logs'
    initInfoTogglers()
    initLogSearchForm()
    initLogsPagination()

initLogSearchForm = ->
  $logs = $('.logs')
  $searchForm = $logs.find('#search_form')
  
  jQuery.datepicker.dpDiv.appendTo($('body'))
  $logs.find('#start_date, #end_date').each ->
    $(this).datepicker({ maxDate: '+0d' })
  
  $logs.find('#submit_button').hide() if @browserSupportsPushState
  $logs.find('#reset_form').hide()
  
  $(document.body).on 'click', '.logs #reset_form', resetSearchForm
  
  $(document.body).on 'submit', '.logs #search_form', ->
    $.get(this.action, serializeFilter(), null, "script")
    history.pushState(null, document.title, $('#search_form').attr('action') + serializeFilter(true)) if window.browserSupportsPushState
    false
  
  $searchForm.find('#client').select2
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
  
  $searchForm.find('#vm_or_user').select2
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
  
  $searchForm.find('#site').select2
    width: 'resolve'
  
  $searchForm.find('#type').select2
    width: 'resolve'
    
  $searchForm.on 'change', '#start_date, #end_date, #site, #type, #client, #vm_or_user', submitForm
  
  window._logsAjaxSend ||= $(document).ajaxSend (e, xhr, settings) ->
    if settings.dataType is 'script' and window.pageIs 'logs'
      $logs.find('#searching img').fadeIn()
        
  window._logsAjaxComplete ||= $(document).ajaxComplete (e, xhr, settings) ->
    if settings.dataType is 'script' and window.pageIs 'logs'
      $logs.find('#searching img').fadeOut()
      if reset
        reset = false
      else
        $logs.find('#reset_form').show()
  
initInfoTogglers = ->
  $(document.body).on 'click', '#logs .device_info_toggler', cycleInfo
  $(document.body).on 'click', '#logs .user_toggler', cycleInfo

initLogsPagination = ->
  $(document.body).on 'click', '#logs th a, #logs .pagination a', ->
    $.getScript(this.href)
    history.pushState({getScript: true}, document.title, this.href) if window.browserSupportsPushState
    false

cycleInfo = ->
  $entry = $(this)
  $current = $entry.find('span:visible')
  $current.hide()
  $next = $current.next('span')
  if $next.length == 0
    $entry.find('span:eq(0)').show()
  else
    $next.show()

serializeFilter = (q) ->
  filteredSerialization = []
  unfilteredSerialization = $('#search_form').serialize().split('&')
  for field in unfilteredSerialization
    if field.indexOf('=') isnt (field.length - 1) and field.indexOf('utf') < 0 and field.indexOf('_') isnt 0
      filteredSerialization.push(field)
  (if q and filteredSerialization.length then '?' else '') + filteredSerialization.join('&') 
  
submitForm = ->
  unless resetting
    action = $('#search_form').attr 'action'
    $.get(action, serializeFilter(), null, "script")
    if window.browserSupportsPushState
      if history.state?.turbolinks?
        history.pushState({getScript: true}, document.title, action + serializeFilter(true))
      else
        history.replaceState({getScript: true}, document.title, action + serializeFilter(true))
  
resetSearchForm = ->
  resetting = true
  $searchForm = $('#search_form')
  
  $searchForm.find('#client, #vm_or_user').each ->
    $this.select2('val', '') if ($this = $(this)).val()

  $searchForm.find('#site, #type').each ->
    $(this).select2('val', null)

  $searchForm.find('input').not('#submit_button').each ->
    $(this).val('')
  
  $searchForm.find('select').val('')
  
  reset = true
  resetting = false
  
  $searchForm.submit()
  $('#reset_form').hide()
  
select2Formatter = (el) ->
  $icon = $('#icons .' + el.category + '_icon')
  if $icon.size is 1
    '<img src="' + $icon.attr('src') + '" class="result_icon" height="11" width="11" /> ' + el.id
  else
    el.id
  
initialSelect = (el, callback) ->
  val = el.val().split('$$')
  callback
    id: val[1]
    category: val[0]

  