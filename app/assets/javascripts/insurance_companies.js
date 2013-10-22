

$(document).ready(function() {
	
  $('#insurance_company_state').keyup(function(){
  	$('#insurance_company_state').val( ($('#insurance_company_state').val()).toUpperCase());
  });  // end patient_state
  
}); // end document ready