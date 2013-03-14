@pstateAvailable = (history && history.pushState)
@initialLoad = true

$ ->
  initPage()

  $(document).on 'page:load', initPage

initPage = ->
  if pageIs 'sites', 'index'
    initNameFilterExplanationDialog()
    
  if pageIs 'sites', ['new', 'edit', 'create', 'update']
    initNameFilterExplanationDialog()
    initNameFilterChecker()
    
  if pageIs 'sites', 'show'
    $('.initial_throbbler').filter(':last').one 'load', initSitesShow
          
initSitesShow = ->
  window.site_list = new SiteList
  window.site_list.addSites()
  
  $('#main_throbbler img').hide()
  $('#main_throbbler').ajaxError ->
    $('img', this).hide('slide', {direction: 'right'})
    
  $('.show').one 'click', window.site_list.build
  $('#refresh_image').click window.site_list.refresh
  window.site_list.load() if window.site_list.sites?
  new AutoUpdater
  
initNameFilterExplanationDialog = ->
  $('#name_filter_explanation').dialog({
    autoOpen: false
    title: "Name Filters"
    minWidth: 600
  })
  $(document.body).on 'click', '.name_filter_explanation_button_inline', ->
    $('#name_filter_explanation').dialog('open')

initNameFilterChecker = ->
  $('#searching', '#client_matches').hide()
  $('#client_matches').hide()
  $('#reset_name_filter').hide()
  $(document.body)
    .on('click', '#reset_name_filter', resetNameFilter)
    .on('change', '#site_name_filter', checkForFilterMatches)
  if $('#site_name_filter').size() is 1 and $('#site_name_filter').val()?.length isnt 0
    orig_filter = $('#site_name_filter').val()
    checkForFilterMatches() 
    $('#site_name_filter').data('original_filter', orig_filter)
  
checkForFilterMatches = ->
  $('#client_matches').show()
  $('#searching', '#client_matches').show()
  $('#reset_name_filter').show() if $('#site_name_filter').data('original_filter')?
  $('#matches', '#client_matches').empty()
  params = {filter: $('#site_name_filter').val()}
  url = $('#client_matches').data('url') + '?' + $.param(params)
  $.getScript(url)

resetNameFilter = ->
  $('#site_name_filter').val($('#site_name_filter').data('original_filter')).change()
  $('#reset_name_filter').hide()


