options = 
	chart:
		renderTo: "chart"
		defaultSeriesType: "column"
	credits:
		enabled: false
	title:
		text: "Total Logins Per Year"
	tooltip:
		formatter: ->
			'<b>' + this.series.name.replace("<br/>", " ") + '</b>(' + this.x.replace("<br/>", " ") + '): ' + this.y
	yAxis:
		title:
			text: "Logins"
	legend:
		enabled: false