@initialLoad = true

$ ->
  initPage()

  $(document).on 'page:load', initPage
  $(document).on 'page:restore', ->
    Turbolinks.visit location.href if pageIs 'sites', 'index'

initPage = ->
  if pageIs 'sites', 'index'
    initNameFilterExplanationDialog()
    initSitesPagination()
    
  if pageIs 'sites', ['new', 'edit', 'create', 'update']
    initNameFilterExplanationDialog()
    initNameFilterChecker()
    
  if pageIs 'sites', 'show'
    $lastThrobbler = $('.initial_throbbler').filter(':last')
    $lastThrobbler.one 'load', initSitesShow
    $lastThrobbler.attr 'src', $lastThrobbler.attr('src')
          
initSitesShow = ->
  window._siteList = new SiteList
  window._siteList.addSites()
  
  $mainThrobbler = $('#main_throbbler')
  $mainThrobbler.find('img').hide()
  $mainThrobbler.ajaxError ->
    $('img', this).hide('slide', {direction: 'right'})
    
  $('.show').one 'click', window._siteList.build
  $('#refresh_image').click window._siteList.refresh
  window._siteList.load() if window._siteList.sites?
  new AutoUpdater

initSitesPagination = ->
  $(document.body).on 'click', '#sites th a:not(.dialog_open), #sites .pagination a', ->
    $.getScript this.href
    history.pushState({getScript: true}, document.title, this.href) if window.browserSupportsPushState
    false

initNameFilterExplanationDialog = ->
  $nameFilterExplanation = $('#name_filter_explanation')
  $nameFilterExplanation.dialog
    autoOpen: false
    title: "Name Filters"
    minWidth: 600
  $(document.body).on 'click', '.name_filter_explanation_button_inline', ->
    $nameFilterExplanation.dialog 'open'

initNameFilterChecker = ->
  $clientMatches = $('#client_matches')
  $siteNameFilter = $('#site_name_filter')
  
  $clientMatches.find('#searching').hide()
  $clientMatches.hide()
  $('#reset_name_filter').hide()
  
  $(document.body)
    .on('click', '#reset_name_filter', resetNameFilter)
    .on('change', '#site_name_filter', checkForFilterMatches)

  if $siteNameFilter.size() is 1 and $siteNameFilter.val()?.length isnt 0
    originalFilter = $siteNameFilter.val()
    checkForFilterMatches() 
    $siteNameFilter.data('original_filter', originalFilter)
  
checkForFilterMatches = ->
  $clientMatches = $('#client_matches')
  $siteNameFilter = $('#site_name_filter')
  
  $clientMatches.show().find('#searching').show()
  $('#reset_name_filter').show() if $siteNameFilter.data('original_filter')?
  $clientMatches.find('#matches').empty()
  
  params = {filter: $siteNameFilter.val()}
  url = $clientMatches.data('url') + '?' + $.param(params)
  $.getScript url

resetNameFilter = ->
  $siteNameFilter = $('#site_name_filter')
  $siteNameFilter.val($siteNameFilter.data('original_filter')).change()
  $('#reset_name_filter').hide()


