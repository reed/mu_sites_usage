initialLoad = false
$ -> 
  if $('body').hasClass('popup')
    $('.sites').find('.throbbler_container')
      .hide()
      .ajaxError ->
        $(this).hide()
        header = $(this).parent()
        $('.summary', header).show()

    $('.device').each ->
      $('span:gt(0)', this).not('.user_toggler').hide()
      $('.uid', this).hide()
    $('.hide_button, .selected').one('click', closeSite)
    $('.refresh_button').click(refreshSite)
    height = $('#site_list').height() + 100
    scrWidth = screen.width
    if scrWidth > 1600
      width = 1600
    else
      width = scrWidth
    
    window.resizeTo(width, height)

closeSite = ->
  window.close()
  
refreshSite = ->
  if $(this).attr('id') is "refresh_image"
    $('.summary').hide()
    $('.throbbler_container').show()
    siteNames = []
    $('.site_block').each ->
      siteNames.push $(this).data('site-name')
    siteName = siteNames.join('/')  
  else
    header = $(this).parent()
    $('.summary', header).hide()
    $('.throbbler_container', header).show() unless initialLoad
    pane = $(this).parent().next('.site_pane')
    siteName = pane.data('site-name')
  $.getJSON('/sites/refresh/' + siteName, (data) ->
    $.each(data, (id, clients) -> 
      siteHeader = $('.site_header[data-site=' + id + ']')
      sitePane = $('.site_pane[data-site=' + id + ']')
      newClients = $(clients).css('opacity', '0')
      $('.device', newClients).each ->
        $('span:gt(0)', this).not('.user_toggler').hide()
        $('.uid', this).hide()
      newHeight = (26 * Math.ceil($('.device', newClients).length / 5)) + 2
      newHeight = newHeight + "px"
      sitePane.html(newClients)
      $('.available_count', siteHeader).text($('.available', sitePane).length)
      $('.unavailable_count', siteHeader).text($('.unavailable', sitePane).length)
      $('.offline_count', siteHeader).text($('.offline', sitePane).length)
      $('.throbbler_container', siteHeader).hide()
      $('.summary', siteHeader).show()
      sitePane.animate({height: newHeight}, 500)
      newClients.animate({opacity: 1}, 500)
    )
  )


