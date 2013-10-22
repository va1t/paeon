
function setup_patient_diag_code(){
      
  // Adding Diagnosis codes
  // change the default css to visible and hide it with js.
  $('#diag_form').css('visibility', 'visible');
  $('#diag_form').hide();
  
  
  // change the default behavior of the diag add button
  $('#add_diag').click(function(evt){
  	$('#add_diag').hide();
  	$('#idiagnostic_selection_dsm').prop('checked', true);  // set default radio button to icd9
  	$('#diag_form').css('height', '100px');  	
  	$('#diag_form').slideDown();
  	evt.preventDefault();
  }); // end add_diag button 
}; // end setup_patient_cpt_code


function setup_diag_radio_buttons(){
  // setup the radio buttons on the show form
  $('.select_radio').change(function(){        
    $('#idiagnostic_dsm_code').slideUp();    
    $.get('/patients/ajax_diagnosis.js', $(this).serialize());
  });  // end setup radio buttons	
}; // end of setup_diag_radio_buttons



function setup_cpt_code_dropdowns(){	
	$('.code_tag').change(function(){
		// get the selected value
		var value = $(this).val();		
		// get the id and trim it 
		var id = $(this).attr('id');
		var preid = id.replace("cpt_code", "");
		// set the 4 modifier field s to blank
		$("#" + preid + "modifier1 option[value='']").attr('selected', true);
		$("#" + preid + "modifier2 option[value='']").attr('selected', true);
		$("#" + preid + "modifier3 option[value='']").attr('selected', true);
		$("#" + preid + "modifier4 option[value='']").attr('selected', true);
		// find the value in the rate dropdown that matchs the cpt selected
		var rate_element = "#" + preid + "rate_id";	    
	    $(rate_element + " option:contains(" + value + ")").attr('selected', 'selected');
	});	// end of code_tage change
};



// setup the events on first and last name to trigger a check for duplicates
function setup_check_duplicate(){
	$('#patient_first_name').change(function(){
		check_duplicate()});
	$('#patient_last_name').change(function(){
		check_duplicate()});
}; // end setup_check_duplicate


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
			$.get('/patients/search.js', $(this).serialize());
		}
	});
};  // end setup_search

// sends ajax request to check for duplicate patient name
function check_duplicate(){	
	var fname = $('#patient_first_name').val();
	var lname = $('#patient_last_name').val();
	
	//both the first and last name needs to be filled before we check for duplicates
	if ($.trim(fname).length > 0 && $.trim(lname).length > 0){	
		data = $('#patient_first_name').serialize() + '&' + $('#patient_last_name').serialize()		
		$.get('/patients/check_duplicate.js', data);
	};	
}; // end check_duplicate


$(document).ready(function() {
	
  // capitalize the state entry	
  $('#patient_state').keyup(function(){
  	$('#patient_state').val( ($('#patient_state').val()).toUpperCase());
  });  // end patient_state
  
  setup_patient_diag_code(); 
  setup_diag_radio_buttons();
  setup_cpt_code_dropdowns();
  setup_search();
  setup_check_duplicate();
  
}); // end document ready