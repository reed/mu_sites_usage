// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery-ui-1.8.17.custom.min
//= require jquery.cookie
//= require jquery.tablesorter.min
//= require jquery.tablesorter.pager
//= require jquery.purr
//= require best_in_place
//= require jquery_ujs
//= require table2CSV
//= require highcharts/highcharts
//= require highcharts/themes/dark-green
//= require_directory .

$(function(){
	resize_menu();
	$(window).resize(resize_menu);
	$('a.button, input[type="button"], input[type="submit"]').each(function(){
		$(this).button();
	});
	setTimeout(hide_flashes, 4000);
});

function resize_menu(){
	if ($('#main_nav').height() > ($(window).height() - 20)){
		var site_list = $('#main_nav ul.menu ul');
		if (site_list.size() == 1){
			site_list.height($(window).height() - ($('#main_nav').height() - site_list.height()) - 40);
			site_list.css('overflowY', 'scroll');
		}
	}
}

function hide_flashes(){
	$('.flash').each(function(){
		$(this).fadeOut('slow', function(){
			$(this).remove();
		});
	});
}