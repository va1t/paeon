

// setup the search function in the index screen
function setup_search(){
	// stop the default action og submitting the form with a return key
	$('#search').keypress(function(e){
		if (e.which == 13){			
			e.preventDefault();
			return false;
		}		
	});
	
	// for every key up check the length.  if greater than 2 the submit query
	$('#search').keyup(function(){
		//get the value		
		var value = $(this).val();		
		if (value.length > 2){
			$.get('/patients_providers/search.js', $(this).serialize() + "&" + $('#provider').serialize());
		}
	});
};  // end setup_search




$(document).ready(function() {
  
  setup_search();
  
}); // end document ready
