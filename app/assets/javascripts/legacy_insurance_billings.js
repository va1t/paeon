


/**********************************************
* edit page js functions
***********************************************/
  
// initialize the fields for the new and edit pages
function initialize_new_edit_page(){    
  $('#insurance_billing_provider_rate_id').hide();
  if ($('#insurance_billing_provider_rate_id option').length > 0){
	$('#insurance_billing_provider_rate_id').slideDown();
  };
  $('#insurance_billing_provider_office_id').hide();
  if ($('#insurance_billing_provider_office_id option').length > 0){
	$('#insurance_billing_provider_office_id').slideDown();
  };  
  setup_select_group();
  setup_select_provider();
  setup_radio_provider();
  setup_radio_group();
};

// for the new and edit pages
// setup the select group change action
function setup_select_provider(){
  $('#insurance_billing_provider_id').change(function(){
    if ($('#insurance_billing_selection_provider').attr('checked')) {
      $('#insurance_billing_provider_rate_id').slideUp();
      $('#insurance_billing_provider_office_id').slideUp();
      $.get('/insurance_billings/ajax_rates.js', $(this).serialize());
      $.get('/insurance_billings/ajax_office.js', $(this).serialize());
      data = $(this).serialize() + '&' + $('#insurance_billing_patient_id').serialize();
      $.get('/insurance_billings/ajax_account.js', data);
    };
  });	
}

// for the new and edit pages
// setup the select provider change action
function setup_select_group(){
  $('#insurance_billing_group_id').change(function(){      
    if ($('#insurance_billing_selection_group').attr('checked')) {
      $('#insurance_billing_provider_rate_id').slideUp();
      $('#insurance_billing_provider_office_id').slideUp();
      $.get('/insurance_billings/ajax_rates.js', $(this).serialize());
      $.get('/insurance_billings/ajax_office.js', $(this).serialize());
      data = $(this).serialize() + '&' + $('#insurance_billing_patient_id').serialize();
      $.get('/insurance_billings/ajax_account.js', data);
    };
    $.get('/insurance_billings/ajax_provider.js', $(this).serialize());
  });	
}
  
  
// setup the radio buttons on the new and edit pages
function setup_radio_provider(){
  $('#insurance_billing_selection_provider').change(function(){        
    $('#insurance_billing_provider_rate').slideUp();
    $('#insurance_billing_provider_office_id').slideUp();    
    $.get('/insurance_billings/ajax_rates.js', $('#insurance_billing_provider_id').serialize());
    $.get('/insurance_billings/ajax_office.js', $('#insurance_billing_provider_id').serialize());
    data = $('#insurance_billing_provider_id').serialize() + '&' + $('#insurance_billing_patient_id').serialize();
    $.get('/insurance_billings/ajax_account.js', data);
  });
}; // end setup the provider radio button

function setup_radio_group(){
  $('#insurance_billing_selection_group').change(function(){    
    $('#insurance_billing_provider_rate').slideUp();
    $('#insurance_billing_provider_office_id').slideUp();
    $.get('/insurance_billings/ajax_rates.js', $('#insurance_billing_group_id').serialize());
    $.get('/insurance_billings/ajax_office.js', $('#insurance_billing_group_id').serialize());
    data = $('#insurance_billing_group_id').serialize() + '&' + $('#insurance_billing_patient_id').serialize();
    $.get('/insurance_billings/ajax_account.js', data);
  });
}; // end setup the group provider radio button
  
function setup_procedures(){
  // change the default css to visible and hide it with js.
  $('#cpt_form').css('visibility', 'visible');
  $('#cpt_form').hide();
	
  // change the default behavior of the new button to use the form on the show page and not call the new form.
  $('#add_cpt').click(function(evt){
  	$('#add_cpt').hide();  	
  	$('#cpt_form').css('height', '140px');
  	$('#cpt_form').slideDown();
  	evt.preventDefault();  	  
  });  // end new cpt code	
};

function setup_diagnostics(){
  // Adding Diagnosis codes
  // change the default css to visible and hide it with js.
  $('#diag_form').css('visibility', 'visible');
  $('#diag_form').hide();
  
  // change the default behavior of the diag add button
  $('#add_diag').click(function(evt){
  	$('#add_diag').hide();
  	$('#idiagnostic_selection_dsm').prop('checked', true);  // set default radio button to icd9
  	$('#diag_form').css('height', '120px');
  	$('#diag_form').slideDown();
  	evt.preventDefault();
  }); // end add_diag button 
  
  // setup the radio buttons on the show form
  $('.select_radio').change(function(){        
    $('.select_tag').slideUp();    
    $.get('/patients/ajax_diagnosis.js', $(this).serialize());
  });  // end setup radio buttons

};

  
$(document).ready(function() {
  
  initialize_new_edit_page();
  setup_procedures();
  setup_diagnostics();

});

