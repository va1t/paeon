
// setup to handle same address as patient checkbox
function setup_same_address_patient(){
  $('#subscriber_same_address_patient').change(function(){  	  	
  	if ($('#subscriber_same_address_patient').is(':checked')) {  		
  	  data = $(this).serialize() + '&' + $('#subscriber_patient_id').serialize();
      $.get('/patients/subscribers/ajax_addr', data );
   };
  });   
};  // end setup_same_address_patient


// setup to handle same address as patient checkbox
function setup_same_as_patient(){
  $('#subscriber_same_as_patient').change(function(){  	  	
  	if ($('#subscriber_same_as_patient').is(':checked')) {  		
  	  data = $(this).serialize() + '&' + $('#subscriber_patient_id').serialize();
      $.get('/patients/subscribers/ajax_subscriber', data );
   };
  });   
};  // end setup_same_address_patient




$(document).ready(function() {
	  
  setup_same_address_patient();
  setup_same_as_patient();
  
  
}); // end document ready