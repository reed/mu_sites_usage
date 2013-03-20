class @PageAnimator
  constructor: ->
    @throbber = null
    $ => @createSpinner()
    $(document)
      .on('page:load', => @createSpinner())
      .on('page:fetch', => @start())
      .on('page:receive', @finish)
      .on 'page:restore', =>
        $('#main_nav h1 a canvas').remove()
        @createSpinner()
  
  createSpinner: ->
    @throbber = new Throbber(
      color: '#3297cb'
      size: 70
      padding: 50
    ).appendTo($('#main_nav h1 a')[0])
  
  start: ->
    $('#logo').addClass 'spinner'
    @throbber.start()
    $('html').fadeTo 'fast', 0.9
  
  finish: ->
    $('#logo').removeClass 'spinner'
    $('html').fadeTo 'fast', 1.0