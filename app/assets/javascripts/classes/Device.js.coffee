class @Device
  constructor: (@container) ->
    @container.find('span:gt(0)').not('.user_toggler').hide()
    @container.find('.uid').hide()
    @container.click @cycleInfo
  
  cycleInfo: ->
    device = $(this)
    current = $('span.cycle:visible', device)
    if current.next('span.cycle').length == 0
      current.hide()
      $('span.cycle:eq(0)', device).show()
    else
      current.hide()
      current.next('span.cycle').show()