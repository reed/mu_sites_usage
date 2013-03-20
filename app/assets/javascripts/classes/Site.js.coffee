class @Site
  constructor: (@container) ->
    @devices = @container.find('.device')
    @header = @container.find('.site_header')
    @pane = @container.find('.site_pane')
    @toggle_button = @container.find('.toggle_button')
    @id = @container.data 'site'
    @name = @container.data 'site-name'
    @menu_link = $('a', "#site_#{@id}")
    
    @setupThrobbler()
    @setupDevices() 
    @updateMenu 'init'
    @bindCallbacks()
    
  setupThrobbler: ->
    @throbbler = @container.find('.throbbler_container')
    @throbbler.hide()
    @throbbler.ajaxError =>
      @throbbler.hide()
      @header.find('.summary').show()
  
  setupDevices: ->
    new Device $(device) for device in @devices
  
  bindCallbacks: ->
    @container.find('.hide_button').one 'click', =>
      @menu_link.unbind 'click'
      window.site_list.remove @id
    @menu_link.one 'click', =>
      window.site_list.remove @id
    @container.find('.refresh_button').click(window.site_list.refresh)
    @toggle_button.one('click', @showDetails)
      
  updateMenu: (action) ->
    if action is 'init'
      @menu_link.removeClass('show').addClass('selected')
    else if action is 'remove'
      @menu_link.removeClass('selected').addClass('show').one('click', window.site_list.build)
  
  hide: ->
    @container.animate {height: '0px'}, 500, =>
      @container.remove()
      @updateMenu 'remove'
    history.replaceState(history.state, document.title, location.href.replace("/" + @name, "")) if pstateAvailable
      
  refresh: (clients) ->
    newClients = $(clients).css 'opacity', '0'
    @devices = newClients.find('.device')
    @setupDevices()
    if @devices.length > 0
      newHeight = (26 * Math.ceil(@devices.length / 5)) + 2
      newHeight = newHeight + 'px'
    else
      $('.toggle_button, .refresh_button', @header).hide()
    @pane.html newClients
    @updateCounts()
    @throbbler.hide()
    @header.find('.summary').show()
    if @toggle_button.text() == 'Basic'
      @toggle_button.unbind('click').one('click', @showDetails).click()
    else
      @pane.animate({height: newHeight}, 500) if newHeight?
      newClients.animate({opacity: 1}, 500)
    if initialLoad
      initialLoad = false if window.site_list.container.data('sites').length is 0
    @updateTime()
    
    
  updateCounts: ->
    @header.find('.available_count').text @pane.find('.available').length
    @header.find('.unavailable_count').text @pane.find('.unavailable').length
    @header.find('.offline_count').text @pane.find('.offline').length
  
  updateTime: ->
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
  
    formatted = hours + ":" + minutes + " " + ampm
    
    window.origColor ||= $('#last_updated').css("color")
  
    $('#last_updated').text(formatted).css("color", "#FFFFFF").animate({ color: origColor }, 2000)

  showDetails: =>
    detailsHeader = $('<tr class="details_table_header"></tr>')
    $('<th>Hostname</th>').appendTo(detailsHeader)
    $('<th>MAC Address</th>').appendTo(detailsHeader)
    $('<th>IP Address</th>').appendTo(detailsHeader)
    $('<th>User</th>').appendTo(detailsHeader)
    $('<th>Status</th>').appendTo(detailsHeader)
    detailsTable = $('<table class="details_table"></table>')
    detailsTable.append(detailsHeader).append(@columnizeDetails()).css('opacity', '0')
    @pane.html(detailsTable)
  
    newHeight = @pane.height()
    newHeight = newHeight + "px"
    rowCount = $('.device_row', @pane).length
  
    $('.user:contains("Unknown User")', @pane).text("").addClass('empty_details')
    $('.device_detail span', @pane).not('.user_toggler').show()
    $('.device_row', @pane).each ->
      $('td:gt(0)', this).each ->
        $(this).addClass('centered')
        $('span:not(".user_toggler")', this).addClass('details')
    $('.user_toggler', @pane).click(@toggleUser)
    h = $('.details_table', @pane).height()
    @pane.animate({height: h}, rowCount * 15)
    $('.details_table', @pane).animate({opacity: 1}, 1500)
    $('.vm', @pane).hide()
    $('.name_toggler span', @pane).click(@toggleName)
    @toggle_button.text('Basic').one('click', @hideDetails)
    
  hideDetails: =>
    @toggle_button.text('Details').one('click', @showDetails)
    @container.find('.refresh_button').click()
    
  columnizeDetails: ->
    rows = []
    columnCount = 5
    rows[j] = [] for j in [0..@devices.length - 1]
    for device, i in @devices
      dev = $(device)
      status = dev.data("status") + '_detail'
      light = $('<div>').append($('img:eq(0)', dev).clone()).remove().html()
      typeIcon = $('<div>').append($('.' + dev.data('type'), '#type_icon_reserve').clone()).remove().html()
      for j in [0..columnCount - 1]
        span = $('<div>').append($('span:not(".user_toggler, .vm"):eq(' + j + ')', dev).clone()).remove().html()
        if j == 0
          if $('.vm', dev).text() != "Unknown VM"
            vm = $('<div>').append($('.vm', dev).clone()).remove().html()
            rows[i].push('<td class="device_detail name_toggler ' + status + '">' + light + typeIcon + span + vm + '</td>')
          else
            rows[i].push('<td class="device_detail ' + status + '">' + light + typeIcon + span + '</td>')
        else
          rows[i].push('<td class="device_detail ' + status + '">' + span + '</td>')

    html = ''
    for row in rows
      r = '<tr class="device_row">' + row.join('') + '</tr>'
      html = html + r
    html
    
  toggleUser: ->
    container = $(this).parent('.details')
    $('.user_toggler', container).each ->
      $(this).toggle()
    
  toggleName: ->
    container = $(this).parent('.name_toggler')
    $('span', container).each ->
      $(this).toggle()