json.chart do |chart|
  chart.renderTo "chart"
  chart.defaultSeriesType "column"
end
json.credits do |credits|
  credits.enabled j(false)
end
json.title do |title|
  title.text "Total Logins"
end
json.xAxis do |x|
  x.categories @data.keys
  x.labels do |l|
    l.rotation -45
    l.align "right"
  end
end
json.series Array.new(1) do |series|
    series.data @data.values
    series.name "Logins"
end
json.tooltip Hash.new
json.yAxis do |y|
  y.title do |title|
    title.text "Logins"
  end
end
json.legend do |legend|
  legend.enabled j(false)
end
#json.subtitle do |subtitle|
#  subtitle.text "Subtitle"
#end