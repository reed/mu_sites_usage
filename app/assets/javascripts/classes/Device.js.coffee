class @Device
  constructor: (@container) ->
    @container
      .find('span:gt(0)').not('.user_toggler').hide().end().end()
      .find('.uid').hide().end()
      .click @cycleInfo
  
  cycleInfo: ->
    $device = $(this)
    $current = $device.find('span.cycle:visible').hide()
    if $current.next('span.cycle').length == 0
      $device.find('span.cycle:eq(0)').show()
    else
      $current.next('span.cycle').show()
