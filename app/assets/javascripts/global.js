// setup ajax to send requests for json
$.ajaxSetup({
	beforeSend: function (xhr) {xhr.setRequestHeader("Accept", "text/javascript");}
});


// using masked input plugin
function setup_field_masks(){
   $(".datepicker").mask("99/99/9999");
   $(".phone").mask("(999) 999-9999? x9999");
   $(".ein").mask("99-9999999");
   $(".ssn").mask("999-99-9999");
   $(".zip").mask("99999?-9999");
	// using autonumeric plugin for formatting dollars
	// to have the $ sign add {aSign: '$'} as an option after init
   $('input.dollar').autoNumeric('init', {vMin: '-999999999.99', vMax: '999999999.99'});
};


function capstate(){
	// capitalize the state entry
    $('.capstate').keyup(function(){
  		//$('.capstate').val( ($('.capstate').val()).toUpperCase());
  		$(this).val( ($(this).val()).toUpperCase());
  	});  // end patient_state
};

function enable_tooltips(){
	// tooltips for any element that has a title
	$("[title]").tooltip({
		position: {
			my: "center bottom-20",
			at: "center top",
			using: function( position, feedback ) {
				$( this ).css( position );
				$( "<div>" )
				.addClass( "arrow" )
				.addClass( feedback.vertical )
				.addClass( feedback.horizontal )
				.appendTo( this );
			}
		}
	});
};


function setup_datepicker(){
	$('.datepicker').datepicker({
		showOn: "button",
		buttonImage: '/assets/calendar.png',
		buttonImageOnly: true,
		dateFormat: 'mm/dd/yy',
		changeMonth: true,
        changeYear: true,
        yearRange: "-75:+10" });
};





$(document).ready(function() {

	capstate();
	setup_datepicker();
	setup_field_masks();
	enable_tooltips();


});

