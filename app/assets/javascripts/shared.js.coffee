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
  $body = $('body')
  document.body.page ||= 
    controller: $body.data('controller')
    action: $body.data('action')
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
      $('ul', this).show('blind', {easing: 'easeInOutCubic'}, setContentHeight).addClass('shown')
  ), 1000

initAccordion = ->
  $siteGroup = $('.site_group')
  $siteGroup.on 'mouseenter', ->
    $submenu = $('ul', this)
    unless $submenu.hasClass('shown')
      $siteGroup.off 'mouseenter'
      $submenu.show('blind', {easing: 'easeInOutCubic'}, initAccordion)
      $siteGroup.find('ul.shown').hide('blind', {easing: 'easeInOutCubic'}).removeClass('shown')
      $submenu.addClass('shown')
  
resizeMenu = ->
  $mainNav = $('#main_nav')
  windowHeight = $(window).height()
  if $mainNav.height() > (windowHeight - 20)
    $siteList = $mainNav.find('ul.menu ul')
    if $siteList.size() is 1
      $siteList.height(windowHeight - ($mainNav.height() - $siteList.height()) - 40)
      $siteList.css('overflowY', 'scroll')
  
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
  newHeight = Math.max $('#main_nav').height(), window.innerHeight - 70
  $('#content').css 'minHeight', newHeight
