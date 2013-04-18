$ ->
  initPage()
  
  $(document).on 'page:load', initPage

initPage = ->
  if pageIs 'departments', 'index'
    initDepartmentChartTooltips()
      
  if pageIs 'departments', 'show'
    initSiteChartTooltips()

initDepartmentChartTooltips = ->
  if $('.department_summary').length
    initHover()
    $('.department_summary').each ->
      $department = $(this)
      counts = {
        Available: $department.data 'available'
        Unavailable: $department.data 'unavailable'
        Offline: $department.data 'offline'
      }
      @formatTooltip = (data) ->
        $tooltip = $department.find('.tooltip')
        $tooltip.removeClass('tooltip_Available tooltip_Unavailable tooltip_Offline')
        if data.point.name == "No clients"
          $tooltip.html(data.point.name)
        else
          $tooltip.html(counts[data.point.name] + ' ' + data.point.name).addClass('tooltip_' + data.point.name)
        return false

initHover = ->
  if $('.highcharts-container').length
    $('.highcharts-container').each ->
      $(this).hover ->
        $(this)
          .closest('.department_summary')
          .find('.tooltip')
          .toggleClass('visible')
  else
    setTimeout ( ->
      initHover()
    ), 200
    
initSiteChartTooltips = ->
  if $('.site_summary').length
    $('.site_summary').each ->
      @formatTooltip = (data, total) ->
        if total is 0
          "No Computers"
        else if data.series.name == "Client Types"
          data.point.name.replace("<br/>", " ") + ': ' + ((data.percentage / 100) * total).toFixed(0)
        else
          data.point.name + ": " + ((data.percentage / 100) * total).toFixed(0)
