@browserSupportsPushState =
  window.history and window.history.pushState and window.history.replaceState and window.history.state != undefined
@initialURL = location.href
@popped = false
@timeouts = new Timeouts
new PageAnimator()

$ ->
  initMenu()
  initBestInPlace()
  initButtons()
  initPopstate()
  setContentHeight()
  $(window).bind 'resize', setContentHeight
  window.timeouts.add hideFlashes, 4000
  $(document).on 'page:change', window.timeouts.clear

$(document).on 'page:load', ->
  initMenu()
  initBestInPlace()
  initButtons()
  setContentHeight()
  window.timeouts.add hideFlashes, 4000

@page = ->
  body = $('body')
  document.body.page ||= 
    controller: body.data('controller')
    action: body.data('action')
    to_a: -> [@controller, @action]
    to_s: -> "#{@controller}##{@action}"

@pageIs = (controller, action) ->
  controller = [controller] unless $.isArray controller
  return false unless @page().controller in controller
  return true unless action
  action = [action] unless $.isArray action
  @page().action in action

initMenu = ->
  resizeMenu()
  $(window).bind 'resize', resizeMenu
  $('#main_nav ul.menu ul').hide()
  initAccordion()
  @timeouts.add ( ->
    $('.site_group:has(.selected)').each ->
      $('ul', this).show('blind', {easing: 'easeInOutCubic'}).addClass('shown')
  ), 1000

initAccordion = ->
  $('.site_group').on 'mouseenter', ->
    submenu = $('ul', this)
    unless submenu.hasClass('shown')
      $('.site_group').off 'mouseenter'
      submenu.show('blind', {easing: 'easeInOutCubic'}, initAccordion)
      $('ul.shown', '.site_group').hide('blind', {easing: 'easeInOutCubic'}).removeClass('shown')
      submenu.addClass('shown')
  
resizeMenu = ->
  if $('#main_nav').height() > ($(window).height() - 20)
    site_list = $('#main_nav ul.menu ul')
    if site_list.size() is 1
      site_list.height($(window).height() - ($('#main_nav').height() - site_list.height()) - 40)
      site_list.css('overflowY', 'scroll')
  
initBestInPlace = ->
  $('.best_in_place').best_in_place()
  
initButtons = ->
  $('.buttonset').buttonset()
  $('a.button, input[type="button"], input[type="submit"]').each ->
    $(this).button()
  
initPopstate = ->
  if @browserSupportsPushState
    $(window).bind 'popstate', (e) ->
      unless history.state?.turbolinks?
        e.preventDefault()
        if location.href == initialURL and not window.popped
          window.popped = true
        else
          $.getScript(location.href) if history.state?.getScript?

hideFlashes = ->
  $('.flash').each ->
    $(this).fadeOut 'slow', ->
      $(this).remove()

setContentHeight = ->
  $('#content').css('minHeight', window.innerHeight - 70)
