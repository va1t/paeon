


function setup_patient_select(){
	$('#eob_patient_id').change(function(){
    	$.get('/eob/ajax_patient.js', $(this).serialize());      
    	$('.eob').css('visibility', 'hidden');
    	$('.subscriber_sidebar').css('visibility', 'hidden');
		$('.claim_sidebar').css('visibility', 'hidden');
	});
	
	var url_params = $.url("?");	
	if ($(location).attr('pathname') == "/eobs/new" && url_params.length == 0 ) {
		// hide the claim select
		$('#claim').css('visibility', 'hidden');
		// hide the eob header
		$('.eob').css('visibility', 'hidden');
		// hide each of the right sidebar areas
		$('.patient_sidebar').css('visibility', 'hidden');
		$('.subscriber_sidebar').css('visibility', 'hidden');
		$('.claim_sidebar').css('visibility', 'hidden');		
	};
};  // end of setup patient select


function setup_claim_select(){
	$('#eob_insurance_billing_id').change(function(){
    	$.get('/eob/ajax_claim.js', $(this).serialize());      
	});
	
};   // end of setup_claim select

// setup the detail add button on the edit screen to return the new record sets within the new_form class area
function setup_detail_add(){
  $('#detail_add').click(function(evt){
	var address = $(this).attr("href");
	$.get(address, $('#new_form :input').serialize());
	evt.preventDefault();
	return false;
  });
	
}; // end of detail add


function setup_unassigned_selector(){
	$('#patient_id').change(function(){
		$.get('/eob/ajax_unassigned.js', $(this).serialize());
	});
	$('#provider_id').change(function(){
		$.get('/eob/ajax_unassigned.js', $(this).serialize());
	});
	$('#group_id').change(function(){
		$.get('/eob/ajax_unassigned.js', $(this).serialize());
	});
	$('#payee_id').change(function(){
		$.get('/eob/ajax_unassigned.js', $(this).serialize());
	});
	
};  // end of unassigned selector

$(document).ready(function() {
	setup_patient_select();
	setup_claim_select();
	setup_detail_add();
	setup_unassigned_selector();
  
}); // end document ready
