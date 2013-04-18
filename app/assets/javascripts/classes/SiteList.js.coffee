class @SiteList
  constructor: ->
    @container = $('#site_list')
    @sites = {}
    @container.sortable
      placeholder: "ui-state-active"
      forcePlaceholderSize: true
      handle: '.site_header'
      
  load: ->
    ids = @container.data('sites')
    unless ids.length is 0
      first_id = ids.shift()
      @container.data('sites', ids)
      $('.refresh_button', @sites[first_id].header).click()
      @load()
  
  addSites: ->
    $('.site_block').each (index, site) =>
      @add $(site)
        
  add: (container) ->
    site = new Site container
    @sites[site.id] = site
    
  remove: (id) ->
    @sites[id].hide()
    delete @sites[id]
    
  build: ->
    $throbbler = $('#main_throbbler img')
    $throbbler.show 'slide', {direction: 'right'}, =>
      $link = $(this)
      url = $link.data('url')
      $.get(url, (data) ->
        newSite = window._siteList.add $(data)
        newSite.container.hide().prependTo('#site_list').slideDown( ->
            $throbbler.hide 'slide', {direction: 'right'}
        )
        history.replaceState(window.history.state, document.title, location.href + '/' + newSite.name) if window.browserSupportsPushState
      )
    
  refresh: ->
    unless initialLoad
      $('#main_throbbler img').show 'slide', {direction: 'right'}
      showing = true
    if $(this).attr('id') is 'refresh_image'
      $('.summary').hide()
      $('.throbbler_container').show()
      siteNames = []
      siteNames.push site.name for id, site of window._siteList.sites
      siteName = siteNames.join '/'
    else
      site = window._siteList.sites[$(this).parent().data('site')]
      siteName = site.name
      site.container.find('.summary').hide()
      site.$throbbler.show() unless initialLoad
    $.getJSON('/sites/refresh/' + siteName, (data) ->
      window._siteList.sites[id].refresh(clients) for id, clients of data
      $('#main_throbbler img').hide 'slide', {direction: 'right'} if showing?
    )
