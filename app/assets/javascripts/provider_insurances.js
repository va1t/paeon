
// the ein suffix must be capitalized,  this script ensure it is.
function capsuffix(){
	// capitalize the ein suffix entry	
    $('.suffix').keyup(function(){  		
  		$(this).val( ($(this).val()).toUpperCase());
  	});  // end patient_state	
};



$(document).ready(function() {
	
	capsuffix();
		  
});
