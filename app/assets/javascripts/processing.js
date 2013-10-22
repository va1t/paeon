// monalisa processing controller


$(document).ready(function() {
	
	
 // submit buttons in the claim ready screen
 // allows the three buttons to send the form to different controllers for different processing
 // sumit form for edi processing
 $('#submit_claim').click(function(){
 	$('#claim_ready').attr('action', '/office_ally/process/submit');
 });

  // submit the form for viewing the claim
 $('#view_claim').click(function(){
 	$('#claim_ready').attr('action', '/processing/claim_submit');
 });
 
 // submit the form for printing the claim
 $('#print_claim').click(function(){
 	$('#claim_ready').attr('action', '/processing/print_claim');
 });
  
});