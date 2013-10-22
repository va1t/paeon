
function setup_diagnostics(){
  // Adding Diagnosis codes
  // change the default css to visible and hide it with js.
  $('#diag_form').css('visibility', 'visible');
  $('#diag_form').hide();
  
  // change the default behavior of the diag add button
  $('#add_diag').click(function(evt){
  	$('#add_diag').hide();
  	$('#idiagnostic_selection_dsm').prop('checked', true);  // set default radio button to icd9
  	$('#diag_form').css('height', '125px');
  	$('#diag_form').slideDown();
  	evt.preventDefault();
  }); // end add_diag button 
};

function setup_diag_radio_buttons(){
  // setup the radio buttons on the show form
  $('.select_radio').change(function(){        
    $('.select_tag').slideUp();    
    $.get('/insurance_billings/ajax_diagnosis.js', $(this).serialize());
  });  // end setup radio buttons
	
}; // end setup_diag_radio_buttons


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
	
	$('.rate_tag').change(function(){
		// get the id and trim it 
		var id = $(this).attr('id');
		var preid = id.replace("rate_id", "");
		var override = "#" + preid + "rate_override";
		var total = "#" + preid + "total_charge";
		// if there is no rate overide then dont blank out the total
		if (!($(override).val() > 0)){
			$(total).val("");		
		}
	}); // end of rate_tage change
	
	$('.override').change(function(){
		// get the id and trim it 
		var id = $(this).attr('id');
		var preid = id.replace("rate_override", "");
		var total = "#" + preid + "total_charge";
		$(total).val("");		
	}); // end of rate_override change
	
	$('.sess').change(function(){
		// get the id and trim it 
		var id = $(this).attr('id');
		var preid = id.replace("sessions", "");
		var total = "#" + preid + "total_charge";
		$(total).val("");		
	}); // end if sessions change
	
}; // end of setup_cpt_code_dropdowns


//setup the button to add procedure codes to the insurance billing screen
function setup_proc_add(){
  $('#procedure_add').click(function(evt){
	var address = $(this).attr("href");
	$.get(address, $('#new_form :input').serialize());
	evt.preventDefault();
	return false;
  });
	
}; // end of proc add


$(document).ready(function() {

  setup_diagnostics();
  setup_diag_radio_buttons();
  setup_cpt_code_dropdowns();
  setup_proc_add();

});
