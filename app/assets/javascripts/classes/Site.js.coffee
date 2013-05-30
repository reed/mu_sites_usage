class @Site
  constructor: (@container) ->
    @$devices = @container.find('.device')
    @$header = @container.find('.site_header')
    @$pane = @container.find('.site_pane')
    @$toggleButton = @container.find('.toggle_button')
    @id = @container.data 'site'
    @name = @container.data 'site-name'
    @$menuLink = $('a', "#site_#{@id}")
    
    @setupThrobbler()
    @setupDevices() 
    @updateMenu 'init'
    @bindCallbacks()
    
  setupThrobbler: ->
    @$throbbler = @container.find('.throbbler_container')
    @$throbbler.hide()
    @$throbbler.ajaxError =>
      @$throbbler.hide()
      @$header.find('.summary').show()
  
  setupDevices: ->
    new Device $(device) for device in @$devices
  
  bindCallbacks: ->
    @container.find('.hide_button').one 'click', =>
      @$menuLink.unbind 'click'
      window._siteList.remove @id
    @$menuLink.one 'click', =>
      window._siteList.remove @id
    @container.find('.refresh_button').click(window._siteList.refresh)
    @$toggleButton.one('click', @showDetails)
      
  updateMenu: (action) ->
    if action is 'init'
      @$menuLink.removeClass('show').addClass('selected')
    else if action is 'remove'
      @$menuLink.removeClass('selected').addClass('show').one('click', window._siteList.build)
  
  hide: ->
    @container.animate {height: '0px'}, 500, =>
      @container.remove()
      @updateMenu 'remove'
    history.replaceState(history.state, document.title, location.href.replace("/" + @name, "")) if window.browserSupportsPushState
      
  refresh: (clients) ->
    newClients = $(clients).css 'opacity', '0'
    @$devices = newClients.find('.device')
    @setupDevices()
    if @$devices.length > 0
      newHeight = (26 * Math.ceil(@$devices.length / 5)) + 2
      newHeight = newHeight + 'px'
    else
      $('.toggle_button, .refresh_button', @$header).hide()
    @$pane.html newClients
    @_updateCounts()
    @$throbbler.hide()
    @$header.find('.summary').show()
    if @$toggleButton.text() == 'Basic'
      @$toggleButton.unbind('click').one('click', @showDetails).click()
    else
      @$pane.animate({height: newHeight}, 500) if newHeight?
      newClients.animate({opacity: 1}, 500)
    window.initialLoad = false if initialLoad && window._siteList.container.data('sites').length is 0
    @_updateTime()

  showDetails: =>
    @$pane.html @_detailsTable()
    @_initCells()
    @_alignCells()
    @_revealDetailsTable()
    @_updateToggleButton 'Basic'
    
  hideDetails: =>
    @_updateToggleButton 'Details'
    @container.find('.refresh_button').click()
    
  toggleUser: ->
    for toggler in $(this).parent('.details').find('.user_toggler')
      $(toggler).toggle()
    return
    
  toggleName: ->
    for toggler in $(this).parent('.name_toggler').find('span')
      $(toggler).toggle()
    return
  
  # private helper methods
  
  _revealDetailsTable: ->
    rowCount = @$pane.find('.device_row').length
    $detailsTable = @$pane.find('.details_table')
    
    @$pane.animate { height: $detailsTable.height() }, rowCount * 15
    $detailsTable.animate { opacity: 1 }, 1500
    
  _detailsTable: ->
    $('#details_table_template').tmpl({devices: @_columnizeDetails()}).css('opacity', '0')
  
  _columnizeDetails: ->
    rows = []
    for device in @$devices
      $device = $(device)
      row = 
        status:   $device.data("status") + '_detail'
        light:    $device.copy('img:eq(0)')
        typeIcon: $('#type_icon_reserve').copy '.' + $device.data('type')
        data: []
        vm: false
      for i in [0..4]
        if i == 0 && $device.find('.vm').text() != "Unknown VM"
          row.vm = $device.copy '.vm'
        row.data.push $device.copy 'span:not(".user_toggler, .vm"):eq(' + i + ')'
      rows.push row
    rows

  _initCells: ->
    @$pane.find('.user:contains("Unknown User")')
      .text("")
      .addClass('empty_details')
    .end().find('.device_detail span:not(.user_toggler)')
      .show()
    .end().find('.user_toggler')
      .click(@toggleUser)
    .end().find('.vm')
      .hide()
    .end().find('.name_toggler span')
      .click(@toggleName)
    return

  _alignCells: ->
    for row in @$pane.find('td').not('tr td:first-child')
      $(row)
        .addClass('centered')
        .find('span:not(".user_toggler")')
        .addClass('details')
    return
    
  _updateToggleButton: (text) ->
    @$toggleButton
      .text(text)
      .one 'click', if text is 'Basic' then @hideDetails else @showDetails
    return
  
  _updateCounts: ->
    for status in ['.available', '.unavailable', '.offline']
      @$header.find(status + '_count').text @$pane.find(status).length
    return

  _updateTime: ->
    $lastUpdated = $('#last_updated')
    
    window.origColor ||= $lastUpdated.css("color")
  
    $lastUpdated
      .text(_formattedTime())
      .css("color", "#FFFFFF")
      .animate({ color: origColor }, 2000)  

  _formattedTime = ->
    now = new Date
    hours = now.getHours()
    minutes = now.getMinutes()
    month = now.getMonth() + 1
    day = now.getDate()
    year = now.getFullYear();

    ampm = if hours > 11 then 'pm' else 'am'
    hours = hours - 12 if hours > 12
    hours = 12 if hours is 0
    minutes = "0" + minutes if minutes < 10
    year -= 2000

    hours + ":" + minutes + " " + ampm
    
$.fn.copy = (selector) ->
  $('<div>').append($(this).find(selector).clone()).remove().html()
